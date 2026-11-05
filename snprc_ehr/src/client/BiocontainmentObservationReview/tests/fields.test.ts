import { carryOverOf, COMPLETED, REVIEW_REQUIRED, SCORED_FIELDS } from '../constants/fields';

describe('SCORED_FIELDS', () => {
    test('has the 13 parameters on TXB 904-1, in form order', () => {
        expect(SCORED_FIELDS.map(f => f.name)).toEqual([
            'WeightLoss',
            'TemperatureChange',
            'Responsiveness',
            'HairCoat',
            'Respiration',
            'Petechia',
            'Bleeding',
            'NasalDischarge',
            'FeedEaten',
            'FoodEnrichment',
            'Stool',
            'FluidIntake',
            'Dehydration',
        ]);
    });

    // Guards against the page offering a value CAMP's CK_* constraints reject, which would fail the write-back
    test('allowed values match the CHECK constraints on dbo.BiocontainmentObservation', () => {
        const values = Object.fromEntries(SCORED_FIELDS.map(f => [f.name, f.values]));
        expect(values).toEqual({
            WeightLoss: [0, 1, 2],
            TemperatureChange: [0, 1, 2, 3],
            Responsiveness: [0, 1, 2, 8, 15],
            HairCoat: [0, 1],
            Respiration: [0, 8, 15],
            Petechia: [0, 1, 2, 3],
            Bleeding: [0, 1, 2],
            NasalDischarge: [0, 1],
            FeedEaten: [0, 1],
            FoodEnrichment: [0, 1],
            Stool: ['0', '1', '2D', '2R'],
            FluidIntake: [0, 1, 2],
            Dehydration: [0, 1],
        });
    });
});

describe('carryOverOf', () => {
    test('returns the carry-over column for the six fields that have one', () => {
        expect(carryOverOf('WeightLoss')).toBe('WeightLossCO');
        expect(carryOverOf('TemperatureChange')).toBe('TemperatureChangeCO');
        expect(carryOverOf('Petechia')).toBe('PetechiaCO');
        expect(carryOverOf('FeedEaten')).toBe('FeedEatenCO');
        expect(carryOverOf('FoodEnrichment')).toBe('FoodEnrichmentCO');
        expect(carryOverOf('Dehydration')).toBe('DehydrationCO');
        expect(SCORED_FIELDS.filter(f => f.carryOver)).toHaveLength(6);
    });

    test('returns undefined for fields without one and for unknown fields', () => {
        expect(carryOverOf('Responsiveness')).toBeUndefined();
        expect(carryOverOf('Comment')).toBeUndefined();
    });
});

test('QC state labels match the study QC states', () => {
    expect(REVIEW_REQUIRED).toBe('Review Required');
    expect(COMPLETED).toBe('Completed');
});
