import React, { Children, cloneElement, useMemo } from 'react';
import PropTypes from 'prop-types';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import DraggableHeaderCell from './DraggableHeaderCell';

export type HeaderDropHandler = (source: any, target: any) => void;

export interface DraggableContainerProps {
    children: React.ReactElement;
    onHeaderDrop: HeaderDropHandler;
}

function DraggableContainerImpl(props: DraggableContainerProps) {
    const child = Children.only(props.children) as React.ReactElement<any>;

    // Clone the child and transform its columns to wrap draggable ones with DraggableHeaderCell
    const enhancedChild = useMemo(() => {
        const childProps = child.props;
        
        // If no columns prop, return child as-is
        if (!childProps.columns) {
            return child;
        }

        // Transform columns to wrap renderHeaderCell for draggable columns
        const enhancedColumns = childProps.columns.map((col: any) => {
            // Only wrap columns that are explicitly marked as draggable
            if (!col.draggable) {
                return col;
            }

            // Save the original renderHeaderCell if it exists
            const originalRenderHeaderCell = col.renderHeaderCell;

            return {
                ...col,
                renderHeaderCell: (headerProps: any) => (
                    <DraggableHeaderCell 
                        column={headerProps.column} 
                        onHeaderDrop={props.onHeaderDrop}
                    >
                        {originalRenderHeaderCell ? 
                            originalRenderHeaderCell(headerProps) : 
                            <div>{headerProps.column.name}</div>
                        }
                    </DraggableHeaderCell>
                )
            };
        });

        return cloneElement(child, {
            ...childProps,
            columns: enhancedColumns,
            onHeaderDrop: props.onHeaderDrop
        } as any);
    }, [child, props.onHeaderDrop]);

    return <>{enhancedChild}</>;
}

// Keep runtime prop validation (optional but harmless)
DraggableContainerImpl.propTypes = {
    children: PropTypes.element.isRequired
};

export const DraggableContainer: React.FC<DraggableContainerProps> = (props) => {
    return (
        <DndProvider backend={HTML5Backend}>
            <DraggableContainerImpl {...props} />
        </DndProvider>
    );
};
