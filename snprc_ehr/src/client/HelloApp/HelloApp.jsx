import React from 'react';
import "./helloApp.scss";

const HelloApp = (props) => {
     return (
            <div>
                <div className='header_title'>
                    {props.title}
                </div>
                <div className='header_subtitle'>
                    {props.subtitle}
                </div>
            </div>
    )
};

HelloApp.defaultProps = {
    title: 'Hello',
    subtitle: 'Put your life in the hands of a computer.'
};

export default HelloApp;