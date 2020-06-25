import React from 'react';
import moment from 'moment';

export default class SummaryGridItem extends React.PureComponent {
    
    onClickHandler = () => {
        const { id } = this.props.row
        this.props.print(id);
    }

    render() {
        const {id, acqDate, species} = this.props.row;
        return (
            <tr >
                <td>
                    {id} <button className="btn" onClick={this.onClickHandler}><i className="fa fa-print" aria-hidden="true"></i></button>
                    
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
