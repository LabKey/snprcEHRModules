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

        //window.open(fullPath, '_blank', `location=yes,height=1024,width=1500,status=no,scrollbars=yes,menubar=yes,left=${left}`)
        window.open(fullPath, '_blank', `height=1024,width=1500,left=${left}`)
        
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
          { moment(animalId.time).format('MM/DD/YYYY h:mm:ss A') }
        </td>
        <td>
          { temperature }
        </td>
        <td>
          { animalId.location }
        </td>
      </tr>
    )
  }
}
