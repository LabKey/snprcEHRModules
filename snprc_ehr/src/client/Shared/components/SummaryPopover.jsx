import React, { PureComponent } from 'react'
import { Popover } from 'react-bootstrap'

class SummaryPopover extends PureComponent {
    render() {
        return (
          <Popover
            { ...this.props }
            className="summary-popover"
            id="summary-popover"
          >
            {this.props.message}
          </Popover>

        )
    }
}

export default SummaryPopover
