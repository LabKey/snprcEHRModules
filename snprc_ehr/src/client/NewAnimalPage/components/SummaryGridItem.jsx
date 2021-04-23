import React from 'react'
import moment from 'moment'

export default class SummaryGridItem extends React.PureComponent {
  onClickHandler = () => {
    const { id } = this.props.row
    this.props.print(id)
  }
render() {
    const { id, acqDate, species, selectedOption } = this.props.row
    return (
      <tr>
        <td>
          {id}
          {selectedOption === 'Birth'
            && (
              <button
                aria-label="Print"
                className="btn"
                onClick={ this.onClickHandler }
                title="Print Birth Certificate"
                type="button"
              >
                <i aria-hidden="true" className="fa fa-print" />
              </button>
            )}
        </td>
        <td>
          {moment(acqDate.date).format('MM/DD/YYYY h:mm A')}
        </td>
        <td>
          {species.value}
        </td>
      </tr>
    )
  }
}
