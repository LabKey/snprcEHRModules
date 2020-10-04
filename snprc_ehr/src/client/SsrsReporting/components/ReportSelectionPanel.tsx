import { ReportItem } from '../api/ReportItem'
import React from 'react'
import Select, { OptionsType } from 'react-select'

interface Props {
    handleChange(selectedReport: ReportItem): void;
    reportList: OptionsType<ReportItem>;
    selectedReport: ReportItem;
}

export default class ReportSelectionPanel extends React.Component<Props> {

    handleChange   = (option: ReportItem | null): void => {
        if (option)
          this.props.handleChange(option)
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
