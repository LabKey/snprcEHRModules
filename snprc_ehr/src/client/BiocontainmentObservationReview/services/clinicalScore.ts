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
