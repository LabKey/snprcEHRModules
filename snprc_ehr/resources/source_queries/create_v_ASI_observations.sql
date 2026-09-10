/*
 * Copyright (c) 2026 SNPRC Corporation
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
USE [animal]
GO

SET ANSI_NULLS ON
  GO

SET QUOTED_IDENTIFIER ON
  GO

/*==============================================================*/
/* View: v_ASI_observations                                     */
/*==============================================================*/
-- Source table: dbo.BiocontainmentObservation, as defined in AsiObsServices/src/Database/Animal.dbml.

CREATE VIEW [labkey_etl].[v_ASI_observations] as
-- ==========================================================================================
-- Author:     Ram
-- Create date: 09/10/26
-- Description: Selects ASI Observations records from CAMP's dbo.BiocontainmentObservation
--              for the CAMP to TAC import ETL (resources/etls/ASIObservations.xml)
-- ==========================================================================================
SELECT o.Id as Id,
       o.ObservationDate as date,
       o.Location AS Location,
       o.WeightLoss AS WeightLoss,
       o.WeightLoss_CO AS WeightLossCO,
       o.TemperatureChange AS TemperatureChange,
       o.TemperatureChange_CO AS TemperatureChangeCO,
       o.Responsiveness AS Responsiveness,
       o.HairCoat AS HairCoat,
       o.Respiration AS Respiration,
       o.Petechia AS Petechia,
       o.Petechia_CO AS PetechiaCO,
       o.Bleeding AS Bleeding,
       o.NasalDischarge AS NasalDischarge,
       o.FeedEaten AS FeedEaten,
       o.FeedEaten_CO AS FeedEatenCO,
       o.FoodEnrichment AS FoodEnrichment,
       o.FoodEnrichment_CO AS FoodEnrichmentCO,
       o.Stool AS Stool,
       o.FluidIntake AS FluidIntake,
       o.Dehydration AS Dehydration,
       o.Dehydration_CO AS DehydrationCO,
       o.Comment AS Comment,
       o.tid,
       o.ObjectId as objectid,
       o.EntryDateTm as modified,
       dbo.f_map_username(o.UserName) as modifiedBy,
       tc.created as created,
       tc.createdby as createdby,
       o.timestamp
FROM dbo.BiocontainmentObservation o
            LEFT OUTER JOIN dbo.TAC_COLUMNS AS tc ON tc.object_id = o.ObjectId
       -- select primates only from the TxBiomed colony
            INNER JOIN Labkey_etl.V_DEMOGRAPHICS AS d ON d.id = o.Id

  go

grant SELECT on labkey_etl.V_ASI_OBSERVATIONS to z_labkey

  go
