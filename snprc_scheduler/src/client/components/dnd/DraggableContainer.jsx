import React from 'react';
import PropTypes from 'prop-types';
import { html5DragDropContext } from './html5DragDropContext';
import DraggableHeaderCell from './DraggableHeaderCell';

class DraggableContainerImpl extends React.Component {

    child = React.Children.only(this.props.children);

    render() {
        return (
            <>
                {React.cloneElement(this.child, {...this.props, draggableHeaderCell: DraggableHeaderCell})}
            </>
        )
    }
}

DraggableContainerImpl.propTypes = {
    children: PropTypes.element.isRequired
};

export const DraggableContainer = (props) => {
    return html5DragDropContext(<DraggableContainerImpl {...props}/>);
}