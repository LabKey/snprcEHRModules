import React, { Component, ReactNode } from 'react';
import { DragSource, DropTarget } from 'react-dnd';

interface DraggableHeaderCellProps {
    connectDragPreview: (children: any) => ReactNode;
    connectDragSource: (children: any) => ReactNode;
    connectDropTarget: (children: any) => ReactNode;
    isDragging: boolean;
    isOver?: boolean;
    canDrop?: boolean;
}

class DraggableHeaderCell extends Component<DraggableHeaderCellProps> {
    render() {
        const {
            connectDragPreview,
            connectDragSource,
            connectDropTarget,
            isDragging,
            isOver,
            canDrop
        } = this.props;

        let opacity = 1;
        if (isDragging) {
            opacity = 0.2;
        }

        // set drag source and drop target on header cell
        return connectDragSource(
                connectDropTarget (
                        <div
                                style={{ width: 0, cursor: 'move', opacity }}
                                className={isOver && canDrop ? 'rdg-can-drop' : ''}
                        >
                            {connectDragPreview(this.props.children)}
                        </div>

                )
        );
    }
}

// drop source
function collect(connect, monitor) {
    return {
        connectDragPreview: connect.dragPreview(),
        connectDragSource: connect.dragSource(),
        isDragging: monitor.isDragging(),
    };
}

const headerCellSource = {
    beginDrag(props) {
        return {
            // source column
            key: props.column.key
        };
    },
    endDrag(props, monitor) {
        // check if drop was made in droppable zone
        if (monitor.didDrop()) {
            const source = monitor.getDropResult().source;
            const target = monitor.getDropResult().target;
            return props.onHeaderDrop(source, target);
        }
    }
};

// drop target
const target = {
    drop(props, monitor) {
        const source = monitor.getItem().key;
        const targetKey = props.column.key;
        return {
            source: source,
            target: targetKey
        };
    }
};

function targetCollect(connect, monitor) {
    return {
        connectDropTarget: connect.dropTarget(),
        isOver: monitor.isOver(),
        canDrop: monitor.canDrop(),
        draggedHeader: monitor.getItem()
    };
}

export default DragSource('Column', headerCellSource, collect)(
    DropTarget('Column', target, targetCollect)(DraggableHeaderCell)
);