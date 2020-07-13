import React from 'react'
import moment from 'moment'

export default class SummaryGridItem extends React.PureComponent {
  onClickHandler = () => {
    const { id } = this.props.row
    this.props.print(id)
  }

  render() {
    const { Id, gender, BirthDate } = this.props.row
    return (
      <tr>
        <td>
          {Id}
        </td>
        <td>
          {gender}
        </td>
        <td>
          {moment(BirthDate).format('MM/DD/YYYY h:mm A')}
        </td>
      </tr>
    )
  }
}
