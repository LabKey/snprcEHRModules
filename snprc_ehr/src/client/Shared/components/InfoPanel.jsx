import React from 'react'

export default class InfoPanel extends React.PureComponent {
  render() {
    const messages = this.props.messages && this.props.messages
    const errorMessages = this.props.errorMessages && this.props.errorMessages
    const infoMessages = this.props.infoMessages && this.props.infoMessages
    const includeBullets = this.props.includeBullets

    return (
      <>
        <div className="info-panel">
          <span>
            { messages
              && messages.some(message => { return message.propTest })
              && 'Enter values for the following fields to continue: ' }
            {
              messages
              && messages.map(message => {
                return message.propTest && <span key={ message.colName }> <span className="info-span"> &nbsp;{ message.colName }&nbsp; </span> &nbsp; </span>
              })

            }

            { errorMessages
              && (
                <div className="info-err-div">
                  { errorMessages.map(message => {
                    return message.propTest && <span key={ message.colName }> <span className="info-err-span"> &nbsp;{ message.colName }&nbsp; </span> &nbsp; </span>
                  }) }
                </div>
              ) }
            { infoMessages
              && (
                <div className="info-div">
                  <div className="info-text-span">
                  { infoMessages.map( (message, index) => {
                    const msg = includeBullets ? `${index + 1} ) ${message.value}` : message.value
                    return <div key={ message.key } >{ msg }</div>
                  }) }
                  </div>
                </div>
              ) }

          </span>
        </div>
      </>
    )
  }
}
