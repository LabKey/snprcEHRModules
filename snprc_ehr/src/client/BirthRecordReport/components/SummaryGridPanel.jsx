import React from 'react'
import { Table } from 'react-bootstrap'
import SummaryGridItem from './SummaryGridItem'

export default class SummaryGridPanel extends React.PureComponent {
  render() {
    return (
      <>
        <div className="table-scroll">
          <Table
            bordered condensed hover
            responsive
          >
            <thead>
              <tr>
                <th>Animal Id</th>
                <th>gender</th>
                <th>Birthdate</th>
              </tr>
            </thead>
            <tbody>
              {this.props.summaryData.length === 0 && <tr><td colSpan="3"> No birth records printed </td></tr>}
              {this.props.summaryData.length > 0 && this.props.summaryData.map(row => {
                return (
                  <SummaryGridItem
                    key={ row.Id }
                    row={ row }
                  />
                )
              })}
            </tbody>
          </Table>
        </div>
      </>
    )
  }
}
