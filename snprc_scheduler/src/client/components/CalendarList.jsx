import React from "react";
import Glyphicon from "react-bootstrap/lib/Glyphicon";


class CalendarList extends React.Component {

    searchJSX = (
            <div className="input-group top-bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer"><Glyphicon glyph="search"/></span>
                <input
                        id="calendarSearch"
                        type="text"
                        className="form-control search-input"
                        name="calendarSearch"
                        placeholder="Search timelines" />
                <span className="input-group-addon input-group-addon-buffer" title="Import animal list"><Glyphicon glyph="save"/></span>
                <span className="input-group-addon input-group-addon-buffer" title="Export animal list"><Glyphicon glyph="open"/></span>
            </div>
    );

    render() {
        return <div style={{ minHeight: 290 }}>{this.searchJSX}<div> No timelines found. </div></div>
    }

}

export default CalendarList;