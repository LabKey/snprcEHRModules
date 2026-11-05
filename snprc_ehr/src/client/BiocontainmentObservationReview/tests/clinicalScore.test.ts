import {
    clinicalScore,
    displayScore,
    formScore,
    responsivenessScore,
    scoreLabel,
    scoreOf,
} from '../services/clinicalScore';
import { SCORED_FIELDS } from '../constants/fields';

// Every scored field at 0, as LabKey returns them (Stool is the one varchar)
const zeroRow = (): Record<string, unknown> =>
    SCORED_FIELDS.reduce((row, f) => ({ ...row, [f.name]: f.name === 'Stool' ? '0' : 0 }), {});

describe('scoreOf', () => {
    test('reads numeric values', () => {
        expect(scoreOf(0)).toBe(0);
        expect(scoreOf(15)).toBe(15);
        expect(scoreOf('8')).toBe(8);
    });

    test('scores Stool 2D and 2R as 2, like the tablet and CAMP', () => {
        expect(scoreOf('2D')).toBe(2);
        expect(scoreOf('2R')).toBe(2);
    });

    test('treats empty and non-numeric values as missing', () => {
        expect(scoreOf(null)).toBeUndefined();
        expect(scoreOf(undefined)).toBeUndefined();
        expect(scoreOf('')).toBeUndefined();
        expect(scoreOf('abc')).toBeUndefined();
    });
});

describe('clinicalScore', () => {
    test('is 0 when every field is 0', () => {
        expect(clinicalScore(zeroRow())).toBe(0);
    });

    test('sums every scored field, including Stool', () => {
        const row = { ...zeroRow(), Responsiveness: 8, Petechia: 3, Stool: '2R', Bleeding: 1 };
        expect(clinicalScore(row)).toBe(14);
    });

    test('reaches the euthanasia threshold of 15 on Respiration alone', () => {
        expect(clinicalScore({ ...zeroRow(), Respiration: 15 })).toBe(15);
    });

    test('is incomplete when any scored field is missing', () => {
        const row = zeroRow();
        delete row.Dehydration;
        expect(clinicalScore(row)).toBeUndefined();
    });

    test('ignores carry-over and comment columns', () => {
        expect(clinicalScore({ ...zeroRow(), WeightLossCO: 1, WeightLossComments: 'typo' })).toBe(0);
    });

    test('maximum possible score matches the TXB 904-1 scales', () => {
        const maxRow = SCORED_FIELDS.reduce(
            (row, f) => ({ ...row, [f.name]: f.values[f.values.length - 1] }),
            {} as Record<string, unknown>
        );
        expect(clinicalScore(maxRow)).toBe(49);
    });
});

describe('displayScore', () => {
    test('shows a dash for an incomplete score', () => {
        expect(displayScore(undefined)).toBe('-');
        expect(displayScore(0)).toBe('0');
        expect(displayScore(17)).toBe('17');
    });
});

describe('4-point form', () => {
    test('the score is the Responsiveness value, with no total', () => {
        expect(responsivenessScore({ FoundDead: 0, Responsiveness: 3, Bleeding: 2 })).toBe('3');
    });

    test('the score is FD when the animal was found dead', () => {
        expect(responsivenessScore({ FoundDead: 1, Responsiveness: null })).toBe('FD');
    });

    test('shows a dash when Responsiveness is missing', () => {
        expect(responsivenessScore({ FoundDead: 0 })).toBe('-');
    });
});

describe('formScore', () => {
    test('sums the 15-point form, even when the animal was found dead', () => {
        expect(formScore({ ...zeroRow(), FormType: '15PT', FoundDead: 1, Respiration: 8 })).toBe('8');
    });

    test('uses Responsiveness alone on the 4-point form', () => {
        expect(formScore({ FormType: '4PT', FoundDead: 0, Responsiveness: 4, Respiration: 2 })).toBe('4');
    });

    test('labels the score by form', () => {
        expect(scoreLabel('15PT')).toBe('Clinical Score');
        expect(scoreLabel('4PT')).toBe('Responsiveness Score');
    });
});
