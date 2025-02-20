#include "barretenberg/flavor/goblin_translator.hpp"
#include "barretenberg/flavor/goblin_ultra.hpp"
#include "barretenberg/flavor/ultra.hpp"
#include <benchmark/benchmark.h>

namespace {
auto& engine = numeric::random::get_debug_engine();
}

namespace proof_system::benchmark::relations {

using FF = barretenberg::fr;

template <typename Flavor, typename Relation> void execute_relation(::benchmark::State& state)
{
    using AllValues = typename Flavor::AllValues;
    using SumcheckArrayOfValuesOverSubrelations = typename Relation::SumcheckArrayOfValuesOverSubrelations;

    auto params = proof_system::RelationParameters<FF>::get_random();

    // Extract an array containing all the polynomial evaluations at a given row i
    AllValues new_value;
    // Define the appropriate SumcheckArrayOfValuesOverSubrelations type for this relation and initialize to zero
    SumcheckArrayOfValuesOverSubrelations accumulator;
    // Evaluate each constraint in the relation and check that each is satisfied

    for (auto _ : state) {
        Relation::accumulate(accumulator, new_value, params, 1);
    }
}

void auxiliary_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, AuxiliaryRelation<FF>>(state);
}
BENCHMARK(auxiliary_relation);

void elliptic_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, EllipticRelation<FF>>(state);
}
BENCHMARK(elliptic_relation);

void ecc_op_queue_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinUltra, EccOpQueueRelation<FF>>(state);
}
BENCHMARK(ecc_op_queue_relation);

void gen_perm_sort_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, GenPermSortRelation<FF>>(state);
}
BENCHMARK(gen_perm_sort_relation);

void lookup_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, LookupRelation<FF>>(state);
}
BENCHMARK(lookup_relation);

void ultra_permutation_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, UltraPermutationRelation<FF>>(state);
}
BENCHMARK(ultra_permutation_relation);

void ultra_arithmetic_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::Ultra, UltraArithmeticRelation<FF>>(state);
}
BENCHMARK(ultra_arithmetic_relation);

void translator_decomposition_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorDecompositionRelation<FF>>(state);
}
BENCHMARK(translator_decomposition_relation);

void translator_opcode_constraint_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorOpcodeConstraintRelation<FF>>(state);
}
BENCHMARK(translator_opcode_constraint_relation);

void translator_accumulator_transfer_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorAccumulatorTransferRelation<FF>>(state);
}
BENCHMARK(translator_accumulator_transfer_relation);

void translator_gen_perm_sort_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorGenPermSortRelation<FF>>(state);
}
BENCHMARK(translator_gen_perm_sort_relation);

void translator_non_native_field_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorNonNativeFieldRelation<FF>>(state);
}
BENCHMARK(translator_non_native_field_relation);

void translator_permutation_relation(::benchmark::State& state) noexcept
{
    execute_relation<honk::flavor::GoblinTranslator, GoblinTranslatorPermutationRelation<FF>>(state);
}
BENCHMARK(translator_permutation_relation);

} // namespace proof_system::benchmark::relations
