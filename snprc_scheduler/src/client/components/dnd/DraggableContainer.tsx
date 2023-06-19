import React, { cloneElement, Children, Component } from 'react';
import html5DragDropContext from './html5DragDropContext';
import DraggableHeaderCell from './DraggableHeaderCell';

// TODO: Verify any of this still works
class DraggableContainer extends Component<any> {
    render() {
        return cloneElement(
            Children.only(this.props.children), {
                ...this.props,
                draggableHeaderCell: DraggableHeaderCell,
            }
        )
    }
}

export default html5DragDropContext(DraggableContainer);