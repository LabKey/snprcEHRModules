import React from 'react'

export class LoadingSpinner extends React.PureComponent {
render() {
        const { msg, wrapperClassName } = this.props

        return (
          <span className={ wrapperClassName }>
            <i aria-hidden="true" className="fa fa-spinner fa-pulse" /> {msg}
          </span>
        )
    }
}
LoadingSpinner.defaultProps = {
  msg: 'Loading...',
  wrapperClassName: 'loading-spinner',
}
