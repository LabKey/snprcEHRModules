import React from 'react'
import moment from 'moment'
import { OverlayTrigger } from 'react-bootstrap'
import SummaryPopover from '../../Shared/components/SummaryPopover'
import InfoPanel from '../../Shared/components/InfoPanel'

export default class SummaryPanel extends React.Component {
  handleKeyPress = e => {
    e.preventDefault()
  }
handlePaste = e => {
    e.preventDefault()
  }
render() {
    const { acquisitionType, acqDate, birthDate, gender, dam, sire, animalAccount,
      colony, pedigree, iacuc, ownerInstitution, responsibleInstitution, room, cage,
      diet, sourceLocation } = this.props.newAnimalData
    const { numAnimals } = this.props

    return (
      <>
        <div className="summary-panel__rows">
          <div className="section-header">Acquisition</div>
          <div className="summary-panel__row">  {/* Acquisition */}
            <div className="summary-panel__col date-width">
              <label className="summary-label">Date</label>
              <OverlayTrigger overlay={ (
                <SummaryPopover
                  message={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') }
                  title="Acquisition Date"
                />
              ) }
              >
                <input
                  className="summary-date-input"
                  defaultValue={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col ">
              <label className="summary-label">Type</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ acquisitionType && acquisitionType.label } title="Acquisition Type" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ acquisitionType && acquisitionType.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                />
              </OverlayTrigger>
            </div>
            { sourceLocation
              && (
              <div className="summary-panel__col ">
                <label className="summary-label">Source Location</label>
                <OverlayTrigger overlay={ <SummaryPopover message={ sourceLocation && sourceLocation.label } title="Source Location" /> }>
                  <input
                    className="summary-text-input"
                    defaultValue={ sourceLocation && sourceLocation.label }
                    onKeyPress={ this.handleKeyPress }
                    onPasteCapture={ this.handlePaste }
                  />
                </OverlayTrigger>
              </div>
)}
            { numAnimals && numAnimals !== 1
              && (
              <div className="summary-panel__col ">
                <label className="summary-label summary-label-red"># Animals</label>
                <OverlayTrigger overlay={ <SummaryPopover message={ numAnimals && numAnimals } title="Number of animals" /> } placement="left">
                  <input
                    className="summary-text-input summary-text-input-red"
                    defaultValue={ numAnimals }
                    onKeyPress={ this.handleKeyPress }
                    onPasteCapture={ this.handlePaste }
                  />
                </OverlayTrigger>
              </div>
)}
          </div>
          <div className="section-header">Demographics</div>
          <div className="summary-panel__row"> {/* Demographics */}
            <div className="summary-panel__col date-width">
              <label className="summary-label">Birthdate</label>
              <OverlayTrigger overlay={ (
                <SummaryPopover
                  message={ birthDate && moment(birthDate.date).format('MM/DD/YYYY h:mm A') }
                  title="Birthdate"
                />
              ) }
              >
                <input
                  className="summary-date-input"
                  defaultValue={ birthDate && moment(birthDate.date).format('MM/DD/YYYY h:mm A') }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  style={ { width: '15rem' } }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col">
              <label className="summary-label">Gender</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ gender && gender.label } title="Gender" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ gender && gender.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            {dam
              && (
                <div className="summary-panel__col">
                  <label className="summary-label">Dam</label>
                  <OverlayTrigger overlay={ <SummaryPopover message={ dam && dam.label } title="Dam" /> } placement="left">
                    <input
                      className="summary-text-input"
                      defaultValue={ dam && dam.label }
                      onKeyPress={ this.handleKeyPress }
                      onPasteCapture={ this.handlePaste }
                      style={ { width: '10rem' } }
                      type="text"
                    />
                  </OverlayTrigger>
                </div>
              )}
            {sire
              && (
                <div className="summary-panel__col">
                  <label className="summary-label">Sire</label>
                  <OverlayTrigger overlay={ <SummaryPopover message={ sire && sire.label } title="Sire" /> } placement="left">
                    <input
                      className="summary-text-input"
                      defaultValue={ sire && sire.label }
                      onKeyPress={ this.handleKeyPress }
                      onPasteCapture={ this.handlePaste }
                      style={ { width: '10rem' } }
                      type="text"
                    />
                  </OverlayTrigger>
                </div>
              )}
          </div>
          <div className="section-header">Location</div>
          <div className="summary-panel__row"> {/* Location */}
            <div className="summary-panel__col date-width">
              <label className="summary-label">Date</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') } title="Move Date" /> }>
                <input
                  className="summary-date-input"
                  defaultValue={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col">
              <label className="summary-label">Location</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ room && room.label } title="Location" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ room && room.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            {cage
              && (
                <div className="summary-panel__col">
                  <label className="summary-label">Cage</label>
                  <OverlayTrigger overlay={ <SummaryPopover message={ cage && cage.value } title="Cage" /> } placement="left">
                    <input
                      className="summary-text-input"
                      defaultValue={ cage && cage.value !== undefined ? cage.value : 'N/A' }
                      onKeyPress={ this.handleKeyPress }
                      onPasteCapture={ this.handlePaste }
                      type="text"
                    />
                  </OverlayTrigger>
                </div>
              )}
          </div>
          <div className="section-header">Account, Colony, and Ownership</div>
          <div className="summary-panel__row1">   {/* Account, Colony, and Ownership */}
            <div className="summary-panel__col">
              <label className="summary-label">Account</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ animalAccount && animalAccount.label } title="Account" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ animalAccount && animalAccount.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />

              </OverlayTrigger>

            </div>
            <div className="summary-panel__col">
              <label className="summary-label">Colony</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ colony && colony.label } title="Colony" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ colony && colony.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col">
              <label className="summary-label">IACUC</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ iacuc && iacuc.label } title="IACUC" /> } placement="left">
                <input
                  className="summary-text-input"
                  defaultValue={ iacuc && iacuc.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
          </div>
          <div className="summary-panel__row">   {/* Account, Colony, and Ownership */}
            {pedigree
              && (
                <div className="summary-panel__col">
                  <label className="summary-label">Pedigree</label>
                  <OverlayTrigger overlay={ <SummaryPopover message={ pedigree && pedigree.label } title="Pedigree" /> } placement="left">
                    <input
                      className="summary-text-input"
                      defaultValue={ pedigree && pedigree.label }
                      onKeyPress={ this.handleKeyPress }
                      onPasteCapture={ this.handlePaste }
                      type="text"
                    />
                  </OverlayTrigger>
                </div>
              )}
            <div className="summary-panel__col">
              <label className="summary-label">Owner</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ ownerInstitution && ownerInstitution.label } title="Owner" /> } placement="right">
                <input
                  className="summary-text-input"
                  defaultValue={ ownerInstitution && ownerInstitution.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col">
              <label className="summary-label">Resp. Inst.</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ responsibleInstitution && responsibleInstitution.label } title="Responsible Institution" /> } placement="left">
                <input
                  className="summary-text-input"
                  defaultValue={ responsibleInstitution && responsibleInstitution.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
          </div>
          <div className="section-header">Diet</div>
          <div className="summary-panel__row"> {/* Diet */}
            <div className="summary-panel__col date-width">
              <label className="summary-label">Date</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') } title="Diet Date" /> }>
                <input
                  className="summary-date-input "
                  defaultValue={ acqDate && moment(acqDate.date).format('MM/DD/YYYY h:mm A') }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                />
              </OverlayTrigger>
            </div>
            <div className="summary-panel__col">
              <label className="summary-label">Diet</label>
              <OverlayTrigger overlay={ <SummaryPopover message={ diet && diet.label } title="Diet" /> }>
                <input
                  className="summary-text-input"
                  defaultValue={ diet && diet.label }
                  onKeyPress={ this.handleKeyPress }
                  onPasteCapture={ this.handlePaste }
                  type="text"
                />
              </OverlayTrigger>
            </div>
          </div>
          <InfoPanel
            includeBullets
            infoMessages={ this.props.infoMessages }
          />
        </div>
      </>
    )
  }
}
