import {
    carryOverOf,
    COMPLETED,
    fieldsFor,
    FOUR_POINT_FIELDS,
    HUSBANDRY_FIELDS,
    missingFields,
    notSedatedOf,
    REVIEW_REQUIRED,
    SCORED_FIELDS,
} from '../constants/fields';

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

describe('FOUR_POINT_FIELDS', () => {
    test('has the 9 parameters on the ABSL-4 4-point form, in form order', () => {
        expect(FOUR_POINT_FIELDS.map(f => f.name)).toEqual([
            'Responsiveness',
            'HairCoat',
            'Respiration',
            'Petechia',
            'Bleeding',
            'NasalDischarge',
            'Stool',
            'FluidIntake',
            'Dehydration',
        ]);
    });

    test('allowed values match the 4PT CHECK constraints on dbo.BiocontainmentObservation', () => {
        const values = Object.fromEntries(FOUR_POINT_FIELDS.map(f => [f.name, f.values]));
        expect(values).toEqual({
            Responsiveness: [0, 1, 2, 3, 4],
            HairCoat: [0, 1],
            Respiration: [0, 1, 2],
            Petechia: [0, 1, 2, 3],
            Bleeding: [0, 1, 2],
            NasalDischarge: [0, 1],
            Stool: ['0', '1', '2D', '2R'],
            FluidIntake: [0, 1, 2],
            Dehydration: [0, 1],
        });
    });

    test('has no carry-overs; only Dehydration has NS', () => {
        expect(FOUR_POINT_FIELDS.filter(f => f.carryOver)).toHaveLength(0);
        expect(FOUR_POINT_FIELDS.filter(f => f.notSedated).map(f => f.name)).toEqual(['Dehydration']);
        expect(notSedatedOf('Dehydration')).toBe('DehydrationNS');
        expect(notSedatedOf('Responsiveness')).toBeUndefined();
    });

    // The page fetches columns from SCORED_FIELDS, so a 4-point-only field would never be loaded
    test('every 4-point parameter is also a 15-point parameter', () => {
        const names = SCORED_FIELDS.map(f => f.name);
        FOUR_POINT_FIELDS.forEach(f => expect(names).toContain(f.name));
    });
});

describe('fieldsFor', () => {
    test('picks the field list by form type, defaulting to the 15-point form', () => {
        expect(fieldsFor('4PT')).toBe(FOUR_POINT_FIELDS);
        expect(fieldsFor('15PT')).toBe(SCORED_FIELDS);
        expect(fieldsFor(undefined)).toBe(SCORED_FIELDS);
    });
});

describe('HUSBANDRY_FIELDS', () => {
    // CK_CageCleaning and CK_Water allow 1 and 2; N/A is NULL
    test('offers Cage Cleaning and Water as words for the values CAMP allows', () => {
        expect(HUSBANDRY_FIELDS.map(h => [h.name, h.options])).toEqual([
            [
                'CageCleaning',
                [
                    { value: 1, label: 'Cleaned' },
                    { value: 2, label: 'Changed' },
                ],
            ],
            [
                'Water',
                [
                    { value: 1, label: 'Added' },
                    { value: 2, label: 'Fresh bottle' },
                ],
            ],
        ]);
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

describe('missingFields', () => {
    test('lists the parameters with no value; 0 is a value', () => {
        const row = Object.fromEntries(SCORED_FIELDS.map(f => [f.name, 0]));
        expect(missingFields(row)).toEqual([]);
        expect(missingFields({ ...row, Bleeding: null, Stool: '' }).map(f => f.name)).toEqual(['Bleeding', 'Stool']);
    });

    test('follows the 4-point form: FD needs nothing else, NS needs no Dehydration', () => {
        const fourPoint = { FormType: '4PT', ...Object.fromEntries(FOUR_POINT_FIELDS.map(f => [f.name, 0])) };
        expect(missingFields(fourPoint)).toEqual([]);
        // WeightLoss isn't on the 4-point form, so it is never missing there
        expect(missingFields({ ...fourPoint, WeightLoss: null })).toEqual([]);
        expect(missingFields({ ...fourPoint, Bleeding: null }).map(f => f.name)).toEqual(['Bleeding']);
        expect(missingFields({ ...fourPoint, Dehydration: null, DehydrationNS: 1 })).toEqual([]);
        expect(missingFields({ FormType: '4PT', FoundDead: 1 })).toEqual([]);
    });
});
