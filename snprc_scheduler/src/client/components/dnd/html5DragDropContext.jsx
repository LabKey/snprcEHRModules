import React from 'react';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';

export const html5DragDropContext = (Component) => {
    return (
        <DndProvider backend={HTML5Backend}>
            {Component}
        </DndProvider>
    );
}