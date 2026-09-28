

/********************************************************
  Copyright (c) 2026 SNPRC
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

  This Query Selects BiocontainmentObservations rows edited in TAC so they can be pushed back to
  CAMP's dbo.BiocontainmentObservation.
 ********************************************************/

-- ==========================================================================================
-- Author:     Ram
-- Create date: 09/10/26
-- Description: Selects BiocontainmentObservations rows edited in TAC so they can be pushed back to
--              CAMP's dbo.BiocontainmentObservation via the TAC to CAMP export ETL
--              (resources/etls/ExportBiocontainmentObservations.xml)
-- ==========================================================================================
SELECT
    o.Id,
    o.date AS ObservationDate,
    o.Location,
    o.WeightLoss,
    o.WeightLossCO,
    o.TemperatureChange,
    o.TemperatureChangeCO,
    o.Responsiveness,
    o.HairCoat,
    o.Respiration,
    o.Petechia,
    o.PetechiaCO,
    o.Bleeding,
    o.NasalDischarge,
    o.FeedEaten,
    o.FeedEatenCO,
    o.FoodEnrichment,
    o.FoodEnrichmentCO,
    o.Stool,
    o.FluidIntake,
    o.Dehydration,
    o.DehydrationCO,
    o.Comment,
    o.objectid,
    o.modified,
    o.modifiedBy,
    o.modifiedBy.email AS modifiedByEmail,
    o.created,
    o.createdBy,
    o.Container
FROM study.BiocontainmentObservations o
WHERE o.modifiedBy.email IS NULL OR o.modifiedBy.email NOT LIKE '%@noreply-txbiomed.org'