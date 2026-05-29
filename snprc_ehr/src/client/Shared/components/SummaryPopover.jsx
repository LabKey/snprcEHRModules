/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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
