import React, { PureComponent } from 'react';
import {Popover} from 'react-bootstrap';

class SummaryPopover extends PureComponent {

    render() {
        
        return (
            <Popover 
                {...this.props} 
                id="summary-popover"
                className="summary-popover"
            >
                {this.props.message}
            </Popover>
    
        )
    } 
}

export default SummaryPopover;