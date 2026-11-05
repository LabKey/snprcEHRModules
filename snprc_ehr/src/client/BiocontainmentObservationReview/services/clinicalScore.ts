import { SCORED_FIELDS } from '../constants/fields';

// Mirrors Observation.scoreOf() in ASI-ObsSingle and the CAMP edit screen: Stool "2D"/"2R" scores 2
export const scoreOf = (value: any): number | undefined => {
    if (value === null || value === undefined || value === '') return undefined;
    const score = parseInt(String(value), 10);
    return isNaN(score) ? undefined : score;
};

// Mirrors Observation.clinicalScore(): a plain sum of every scored field; any missing value leaves it incomplete
export const clinicalScore = (row: Record<string, any>): number | undefined => {
    let total = 0;
    for (const f of SCORED_FIELDS) {
        const score = scoreOf(row[f.name]);
        if (score === undefined) return undefined;
        total += score;
    }
    return total;
};

export const displayScore = (score: number | undefined): string => (score === undefined ? '-' : String(score));

// The 4-point form has no total: its score is the Responsiveness value, or FD when the animal was found dead (10/13)
export const responsivenessScore = (row: Record<string, any>): string =>
    Number(row.FoundDead) === 1 ? 'FD' : displayScore(scoreOf(row.Responsiveness));

// Scores are never added up or compared across forms (9/22)
export const formScore = (row: Record<string, any>): string =>
    row.FormType === '4PT' ? responsivenessScore(row) : displayScore(clinicalScore(row));

export const scoreLabel = (formType: string): string =>
    formType === '4PT' ? 'Responsiveness Score' : 'Clinical Score';
