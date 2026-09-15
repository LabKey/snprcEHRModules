export interface ScoredField {
    name: string;
    label: string;
    carryOver?: string;
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

export const REVIEW_REQUIRED = "Review Required";
export const COMPLETED = "Completed"