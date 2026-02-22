export interface Project {
    CostAccount?: string;
    description?: string;
    endDate?: string;
    FeeScheduler?: string;
    Iacuc?: string;
    objectId?: string;
    projectId?: number;
    ProjectItems?: any[];
    ProjectObjectId?: string;
    referenceId?: string;
    revisionNum?: number;
    startDate?: string;
    Veterinarian1?: string;
    Veterinarian2?: string;
    VsNumber?: string;
}

export interface Timeline {
    AnimalAccount?: string;
    Created?: string;
    CreatedByName?: string;
    Description?: string;
    EndDate?: string;
    IsDirty?: boolean;
    IsInUse?: boolean;
    LeadTech?: string;
    Modified?: string;
    ModifiedByName?: string;
    Notes?: string;
    ObjectId?: string;
    QcStateLabel?: string;
    RC?: string;
    RevisionNum?: number;
    RowId?: number;
    savedDraft?: boolean;
    SchedulerNotes?: string;
    StartDate?: string;
    StudyDay0?: string;
    StudyDayNotes?: any[];
    TimelineAnimalItems?: any[];
    TimelineId?: number;
    TimelineItems?: any[];
    TimelineProjectItems?: any[];
}

export interface Animal {
    Age?: string;
    AnimalId?: string;
    assigned?: boolean;
    AssignmentStatus?: string;
    DeathDate?: string;
    DepartureDate?: string;
    EndDate?: string;
    Gender?: string;
    Id?: string;
    IsDeleted?: boolean;
    IsDirty?: boolean;
    status?: string;
    Weight?: number;
}
