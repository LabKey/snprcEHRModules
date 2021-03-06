import React from 'react';
//import ReactDOM from 'react-dom';
//import FullCalendar from 'fullcalendar';
//import 'fullcalendar-reactwrapper/dist/css/fullcalendar.min.css';
//import 'fullcalendar/dist/fullcalendar.css';
// import $ from 'jquery';

class CalendarView extends React.Component {
        constructor(props) {
        super(props);
        this.state = {
        events:[
                    {
                        title: 'All Day Event',
                        start: '2018-09-01'
                    },
                    {
                        title: 'Long Event',
                        start: '2018-09-07',
                        end: '2018-09-10'
                    },
                    {
                        id: 999,
                        title: 'Repeating Event',
                        start: '2018-09-09T16:00:00'
                    },
                    {
                        id: 999,
                        title: 'Repeating Event',
                        start: '2018-09-16T16:00:00'
                    },
                    {
                        title: 'Conference',
                        start: '2018-09-11',
                        end: '2018-09-13'
                    },
                    {
                        title: 'Meeting',
                        start: '2018-09-12T10:30:00',
                        end: '2018-09-12T12:30:00'
                    },
                    {
                        title: 'Birthday Party',
                        start: '2018-09-13T07:00:00'
                    },
                    {
                        title: 'Click for Google',
                        url: 'http://google.com/',
                        start: '2018-09-28'
                    }
                ],		
        }
    }
    
    render() { return <div id="calendar"></div>; }
    
    // componentDidMount() {
    //     $('#calendar').fullCalendar({
    //         header: {
    //             left: 'prev,next today',
    //             center: 'title',
    //             right: 'month,agendaWeek,agendaDay'
    //         },
    //         editable: true,
    //         droppable: true,
    //         events: this.state.events,
    //         drop: function() { },
    //         eventClick: function(item) { console.log(item); }
    //     });
    // }
  }

  export default CalendarView;