#!/usr/bin/env -S node --no-warnings
import { createAztecNodeRpcServer } from '@aztec/aztec-node';
import { deployInitialSandboxAccounts } from '@aztec/aztec.js';
import { createDebugLogger } from '@aztec/foundation/log';
import { fileURLToPath } from '@aztec/foundation/url';
import { NoirWasmVersion } from '@aztec/noir-compiler/versions';
import { createPXERpcServer } from '@aztec/pxe';

import { readFileSync } from 'fs';
import { dirname, resolve } from 'path';

import { setupFileDebugLog } from '../logging.js';
import { createSandbox } from '../sandbox.js';
import { startHttpRpcServer } from '../server.js';
import { github, splash } from '../splash.js';

const { AZTEC_NODE_PORT = 8079, PXE_PORT = 8080 } = process.env;

const logger = createDebugLogger('aztec:sandbox');

/**
 * Creates the sandbox from provided config and deploys any initial L1 and L2 contracts
 */
async function createAndInitializeSandbox() {
  const { aztecNodeConfig, node, pxe, stop } = await createSandbox();
  if (aztecNodeConfig.p2pEnabled) {
    logger.info(`Not setting up test accounts as we are connecting to a network`);
    return {
      aztecNodeConfig,
      pxe,
      node,
      stop,
      accounts: [],
    };
  }
  logger.info('Setting up test accounts...');
  const accounts = await deployInitialSandboxAccounts(pxe);
  return {
    aztecNodeConfig,
    pxe,
    node,
    stop,
    accounts,
  };
}

/**
 * Create and start a new Aztec RPC HTTP Server
 */
async function main() {
  const logPath = setupFileDebugLog();
  const packageJsonPath = resolve(dirname(fileURLToPath(import.meta.url)), '../../package.json');
  const version = JSON.parse(readFileSync(packageJsonPath).toString()).version;

  logger.info(`Setting up Aztec Sandbox v${version} (noir v${NoirWasmVersion}), please stand by...`);

  const { pxe, node, stop, accounts } = await createAndInitializeSandbox();

  const shutdown = async () => {
    logger.info('Shutting down...');
    await stop();
    process.exit(0);
  };

  process.once('SIGINT', shutdown);
  process.once('SIGTERM', shutdown);

  startHttpRpcServer(node, createAztecNodeRpcServer, AZTEC_NODE_PORT);
  logger.info(`Aztec Node JSON-RPC Server listening on port ${AZTEC_NODE_PORT}`);
  startHttpRpcServer(pxe, createPXERpcServer, PXE_PORT);
  logger.info(`PXE JSON-RPC Server listening on port ${PXE_PORT}`);
  logger.info(`Debug logs will be written to ${logPath}`);
  const accountStrings = accounts.length ? [`Initial Accounts:\n\n`] : [];

  const registeredAccounts = await pxe.getRegisteredAccounts();
  for (const account of accounts) {
    const completeAddress = account.account.getCompleteAddress();
    if (registeredAccounts.find(a => a.equals(completeAddress))) {
      accountStrings.push(` Address: ${completeAddress.address.toString()}\n`);
      accountStrings.push(` Partial Address: ${completeAddress.partialAddress.toString()}\n`);
      accountStrings.push(` Private Key: ${account.privateKey.toString()}\n`);
      accountStrings.push(` Public Key: ${completeAddress.publicKey.toString()}\n\n`);
    }
  }
  logger.info(
    `${splash}\n${github}\n\n`
      .concat(...accountStrings)
      .concat(`Aztec Sandbox v${version} (noir v${NoirWasmVersion}) is now ready for use!`),
  );
}

main().catch(err => {
  logger.error(err);
  process.exit(1);
});
