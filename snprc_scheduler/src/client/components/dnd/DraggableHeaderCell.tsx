import React, { ReactElement, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDrag, useDrop } from 'react-dnd';
import type { HeaderDropHandler } from './DraggableContainer';

const TYPE = 'Column';

// Types for react-dnd
interface DragItem {
    key?: string;
    name?: string;
}
type DropResult = { source?: string; target?: string };

export interface DraggableHeaderCellProps {
    column: { key?: string; name?: string } | null | undefined;
    onHeaderDrop: HeaderDropHandler;
    children: React.ReactElement;
}

export default function DraggableHeaderCell(props: DraggableHeaderCellProps): ReactElement {
    const { column, onHeaderDrop, children } = props;

    // Drag source
    const [{ isDragging }, drag, preview] = useDrag<DragItem, DropResult, { isDragging: boolean}>({
        type: TYPE,
        item: { key: column?.key, name: column?.name },
        collect: (monitor) => ({
            isDragging: monitor.isDragging(),
        }),
        end: (_item, monitor) => {
            if (monitor.didDrop()) {
                const result = monitor.getDropResult();
                if (result && result.source && result.target && typeof onHeaderDrop === 'function') {
                    onHeaderDrop(result.source, result.target);
                }
            }
        }
    });

    // Set up custom drag preview
    useEffect(() => {
        // Create a custom preview using canvas
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        if (ctx) {
            // Measure text to size canvas appropriately
            ctx.font = 'bold 14px sans-serif';
            const textWidth = ctx.measureText(column?.name || 'Column').width;
            canvas.width = textWidth + 24;
            canvas.height = 32;
            
            // Draw preview with rounded rectangle background
            ctx.fillStyle = '#4a90e2';
            ctx.roundRect(0, 0, canvas.width, canvas.height, 4);
            ctx.fill();
            ctx.fillStyle = 'white';
            ctx.font = 'bold 14px sans-serif';
            ctx.textBaseline = 'middle';
            ctx.fillText(column?.name || 'Column', 12, 16);
        }
        
        const img = new Image();
        img.src = canvas.toDataURL();
        img.onload = () => {
            preview(img, { captureDraggingState: true });
        };
    }, [column?.name, preview]);

    // Drop target
    const [{ isOver, canDrop }, dropRef] = useDrop<DragItem, DropResult, { isOver: boolean; canDrop: boolean }>({
        accept: TYPE,
        drop: (dragItem: DragItem) => {
            const source = dragItem?.key as string | undefined;
            const target = column?.key as string | undefined;
            // return result consumed by the drag source's end handler
            return { source, target };
        },
        collect: (monitor) => ({
            isOver: monitor.isOver(),
            canDrop: monitor.canDrop(),
        })
    });

    const opacity = isDragging ? 0.6 : 1;

    return (
        <div
            ref={(node: HTMLDivElement | null) => {
                // Compose drag and drop refs on the same DOM node
                drag(node);
                dropRef(node);
            }}
            style={{ width: 0, cursor: 'move', opacity }}
            className={isOver && canDrop ? 'rdg-can-drop' : ''}
        >
            {children}
        </div>
    );
}

// Optional runtime validation (harmless alongside TypeScript)
(DraggableHeaderCell as any).propTypes = {
    column: PropTypes.object.isRequired,
    onHeaderDrop: PropTypes.func.isRequired,
    children: PropTypes.element.isRequired,
};
