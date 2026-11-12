export type FormType = '4PT' | '15PT';

export interface ScoredField {
    carryOver?: string;
    label: string;
    name: string;
    // 4-point Dehydration only: "not sedated", which leaves the value empty. Never called a carry-over (10/13).
    notSedated?: string;
    values: (number | string)[];
}

// Order follows TXB 904-1; values from the CK_* constraints in createBiocontainmentObservation.sql
export const SCORED_FIELDS: ScoredField[] = [
    { name: 'WeightLoss', label: 'Weight Loss', carryOver: 'WeightLossCO', values: [0, 1, 2] },
    { name: 'TemperatureChange', label: 'Temperature Change', carryOver: 'TemperatureChangeCO', values: [0, 1, 2, 3] },
    { name: 'Responsiveness', label: 'Responsiveness', values: [0, 1, 2, 8, 15] },
    { name: 'HairCoat', label: 'Hair Coat', values: [0, 1] },
    { name: 'Respiration', label: 'Respiration', values: [0, 8, 15] },
    { name: 'Petechia', label: 'Petechia', carryOver: 'PetechiaCO', values: [0, 1, 2, 3] },
    { name: 'Bleeding', label: 'Bleeding', values: [0, 1, 2] },
    { name: 'NasalDischarge', label: 'Nasal Discharge', values: [0, 1] },
    { name: 'FeedEaten', label: 'Feed Eaten', carryOver: 'FeedEatenCO', values: [0, 1] },
    { name: 'FoodEnrichment', label: 'Food Enrichment', carryOver: 'FoodEnrichmentCO', values: [0, 1] },
    { name: 'Stool', label: 'Stool', values: ['0', '1', '2D', '2R'] },
    { name: 'FluidIntake', label: 'Fluid Intake', values: [0, 1, 2] },
    { name: 'Dehydration', label: 'Dehydration', carryOver: 'DehydrationCO', values: [0, 1] },
];

// ABSL-4 4-point form (TXB 904-1 ABSL-4 REV 00): no weight, temperature, feed or enrichment, and no carry-overs
export const FOUR_POINT_FIELDS: ScoredField[] = [
    { name: 'Responsiveness', label: 'Responsiveness', values: [0, 1, 2, 3, 4] },
    { name: 'HairCoat', label: 'Hair Coat', values: [0, 1] },
    { name: 'Respiration', label: 'Respiration', values: [0, 1, 2] },
    { name: 'Petechia', label: 'Petechia', values: [0, 1, 2, 3] },
    { name: 'Bleeding', label: 'Bleeding', values: [0, 1, 2] },
    { name: 'NasalDischarge', label: 'Nasal Discharge', values: [0, 1] },
    { name: 'Stool', label: 'Stool', values: ['0', '1', '2D', '2R'] },
    { name: 'FluidIntake', label: 'Fluid Intake', values: [0, 1, 2] },
    { name: 'Dehydration', label: 'Dehydration', notSedated: 'DehydrationNS', values: [0, 1] },
];

// A row whose form is missing is shown as the original 15-point form
export const fieldsFor = (formType: string): ScoredField[] => (formType === '4PT' ? FOUR_POINT_FIELDS : SCORED_FIELDS);

export interface HusbandryField {
    label: string;
    name: string;
    options: { label: string; value: number }[];
}

// Both forms, never scored and no prior value (9/29). Empty means N/A.
export const HUSBANDRY_FIELDS: HusbandryField[] = [
    {
        name: 'CageCleaning',
        label: 'Cage Cleaning',
        options: [
            { value: 1, label: 'Cleaned' },
            { value: 2, label: 'Changed' },
        ],
    },
    {
        name: 'Water',
        label: 'Water',
        options: [
            { value: 1, label: 'Added' },
            { value: 2, label: 'Fresh bottle' },
        ],
    },
];

export const NOT_APPLICABLE = 'N/A';

export const carryOverOf = (field: string): string | undefined => SCORED_FIELDS.find(f => f.name === field)?.carryOver;

export const notSedatedOf = (field: string): string | undefined =>
    FOUR_POINT_FIELDS.find(f => f.name === field)?.notSedated;

export const isMissingValue = (value: unknown): boolean => value == null || value === '';

// Scored parameters on the record's form with no value; the trigger rejects any save or approval until each is filled in.
// On the 4-point form, FD leaves the rest of the form empty and NS leaves Dehydration empty (10/13).
export const missingFields = (row: Record<string, unknown>): ScoredField[] => {
    if (row.FormType === '4PT' && Number(row.FoundDead) === 1) return [];
    return fieldsFor(row.FormType as string).filter(
        f => isMissingValue(row[f.name]) && !(f.notSedated && Number(row[f.notSedated]) === 1)
    );
};

export const REVIEW_REQUIRED = 'Review Required';
export const COMPLETED = 'Completed';
