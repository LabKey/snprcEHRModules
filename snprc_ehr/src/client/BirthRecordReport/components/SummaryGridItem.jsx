/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
