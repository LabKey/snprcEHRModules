CREATE TABLE snprc_ehr.clinical_observation_datasets
(
  rowId Int NOT NULL,
	dataset_name NVARCHAR(255) NOT NULL,
	category_name NVARCHAR(255) NOT NULL,
	sort_order Int NULL,
	Container	entityId NOT NULL,

    CONSTRAINT pk_clinical_observation_datasets PRIMARY KEY (rowId),
    CONSTRAINT FK_clinical_observation_datasets_Container FOREIGN KEY (Container) REFERENCES core.Containers (EntityId)
    );

GO