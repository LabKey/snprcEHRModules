import { ReportType } from '../api/reportList'
import React from 'react'
import Select, { OptionsType } from 'react-select'

interface Props {
    handleChange(selectedReport: ReportType): void;
    reportList: OptionsType<ReportType>;
    selectedReport: ReportType;
}

export default class ReportSelection extends React.Component<Props> {

    handleChange   = (option: ReportType | null): void => {
        if (option)
          this.props.handleChange(option)
        console.log('option: ', option)
    }

    render() {
      const { selectedReport, reportList } = this.props

      return (
        <>
                <label className="field-label-align-close">Select Report</label>
                <Select
                  autoFocus
                  className="shared-dropdown"
                  classNamePrefix="shared-select"
                  id="report-select"
                  isLoading={ !reportList }
                  onChange= { this.handleChange }
                  options={ reportList }
                  placeholder="Select Report"
                  value={ selectedReport || null  }
                />
        </>
      )
    }
}
