import React from 'react'

export class LoadingSpinner extends React.PureComponent {
    static defaultProps = {
        msg: 'Loading...',
        wrapperClassName: 'loading-spinner',
    };

    render() {
        const { msg, wrapperClassName } = this.props

        return (
            <span className={wrapperClassName}>
                <i aria-hidden="true" className="fa fa-spinner fa-pulse" /> {msg}
            </span>
        );
    }
}