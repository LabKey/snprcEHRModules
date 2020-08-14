import React from 'react'
import moment from 'moment'

export default class SummaryGridItem extends React.PureComponent {
  onClickHandler = () => {
    const { id } = this.props.row
    this.props.print(id)
  }

  onClick = () => {
   
        const fullPath =  this.props.row.animalId.url 
        const left = window.screenX + 20

        window.open(fullPath, '_blank', `location=no,height=1024,width=1500,status=no,scrollbars=no,left=${left}`)
        
    }


  render() {
    const { animalId, chipId, temperature } = this.props.row
    return (
      <tr>
        <td>
         { <span className="url-span" onClick={ this.onClick}> { animalId.value } </span> }
        </td>
        <td>
          { chipId }
        </td>
        <td>
          { moment().format('MM/DD/YYYY h:mm:ss A') }
        </td>
        <td>
          { temperature }
        </td>
      </tr>
    )
  }
}
