import React from 'react'
import { Table } from 'react-bootstrap'
import SummaryGridItem from './SummaryGridItem'

export default class SummaryGridPanel extends React.PureComponent {
  render() {
    return (
      <>
        <div className="id-table-scroll">
          <Table
            bordered condensed hover
            responsive
          >
            <thead>
              <tr>
                <th>Animal Id</th>
                <th>Chip Id</th>
                <th>Date</th>
                <th>temperature</th>
                <th>location</th>
              </tr>
            </thead>
            <tbody>
              { this.props.summaryData.length === 0 && <tr><td colSpan="5"> No animals </td></tr> }
              { this.props.summaryData.length > 0 && this.props.summaryData.slice(0).reverse().map(row => {
                return (
                  <SummaryGridItem
                    key={ `${row.chipId}.${Math.floor((Math.random() * 10000)).toString()} ` }
                    row={ row }
                  />
                )
              }) }
            </tbody>
          </Table>
        </div>
      </>
    )
  }
}
