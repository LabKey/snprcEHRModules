import React from 'react'
import ReactDOM from 'react-dom'
import { NewAnimalPage } from "./NewAnimalPage";


const render = () => {
    ReactDOM.render(<NewAnimalPage />, document.getElementById('app'))
}

render()
