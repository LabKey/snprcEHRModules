import React from 'react'
import Select from 'react-select'
import moment from 'moment'
import WrappedDatePicker from '../../Shared/components/WrappedDatePicker'
import InfoPanel from '../../Shared/components/InfoPanel'

export default class DemographicsPanel extends React.Component {

    state = {
        errorMessage: undefined
    }

    componentDidMount = () => {
      console.log('DemographicsPanel mounted')
    }

    render() {
        return (
          <>
            <div className="wizard-panel__rows">
              <div className="wizard-panel__row">
                <div className="wizard-panel__col">
                  <p>Demographic Data Here</p>

                </div>
              </div>

            </div>
            <InfoPanel
              errorMessages={ this.state.errorMessage
                        && [{ propTest: true, colName: this.state.errorMessage }] }

            />
          </>
        )
    }
}
