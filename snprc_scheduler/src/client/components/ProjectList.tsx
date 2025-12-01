/* 
    ==================================================================================
    author:             David P. Smith
    email:              dsmith@txbiomed.org
    name:               snprc_scheduler
    description:        Animal procedure scheduling system     
    copyright:          Texas Biomedical Research Institute
    created:            October 1 2018      
    ==================================================================================
*/
import React, { ChangeEvent, FC, memo, useCallback, useEffect, useMemo, useState } from 'react';
import { filterProjects, selectProject, selectTimeline, setForceRerender, TAB_PROJECTS } from '../actions/dataActions';
import { connect } from 'react-redux';
import { DataGrid } from 'react-data-grid';
import { Project, Timeline } from '../models/models';
import { Dispatch } from 'redux';

interface ProjectListProps {
    accordion?: { tab: number };
    filterProjects: (search: string) => void;
    forceRerender: boolean;
    onSelectProject: (project: Project) => void;
    onSelectTimeline: (timeline?: Timeline) => void;
    projects: Project[];
    selectedProject: null | Project;
    setForceRerender: (render: boolean) => void;
}

const ProjectList: FC<ProjectListProps> = props => {
    const {
        projects,
        selectedProject,
        forceRerender,
        setForceRerender,
        onSelectProject,
        onSelectTimeline,
        filterProjects,
    } = props;

    const [sortColumns, setSortColumns] = useState<{ columnKey: string; direction: 'ASC' | 'DESC' }[]>([
        { columnKey: 'description', direction: 'ASC' },
    ]);

    // Handle force rerender logic
    useEffect(() => {
        if (forceRerender) {
            setForceRerender(false);
        }
    }, [forceRerender, setForceRerender]);

    const columns = [
        { key: 'Iacuc', name: 'IACUC', width: 80, sortable: true },
        { key: 'description', name: 'Description', sortable: true },
        { key: 'revisionNum', name: 'Rev', width: 40, sortable: true },
    ];

    const handleSort = useCallback((newSortColumns: { columnKey: string; direction: 'ASC' | 'DESC' }[]) => {
        setSortColumns(newSortColumns);
    }, []);

    const sortedRows = useMemo(() => {
        if (sortColumns.length === 0) return projects;

        const sortColumn = sortColumns[0];
        if (!projects) return [];

        return [...projects].sort((a: any, b: any) => {
            const aVal = a[sortColumn.columnKey];
            const bVal = b[sortColumn.columnKey];

            if (aVal == null && bVal == null) return 0;
            if (aVal == null) return 1;
            if (bVal == null) return -1;

            const comparison = aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
            return sortColumn.direction === 'ASC' ? comparison : -comparison;
        });
    }, [projects, sortColumns]);

    const onCellClick = useCallback(
        (args: any) => {
            // Select project and empty selected timeline
            onSelectProject(args.row);
            onSelectTimeline();
        },
        [onSelectProject, onSelectTimeline]
    );

    const onSelectedRowsChange = useCallback(
        (selectedRows: Set<number>) => {
            // Handle single row selection - when a row is selected via checkbox or other means
            if (selectedRows.size > 0) {
                const selectedProjectId = Array.from(selectedRows)[0];
                const selectedProject = sortedRows.find((row: Project) => row.projectId === selectedProjectId);
                if (selectedProject) {
                    onSelectProject(selectedProject);
                    onSelectTimeline();
                }
            }
        },
        [sortedRows, onSelectProject, onSelectTimeline]
    );

    const handleProjectSearchChange = useCallback(
        (event: ChangeEvent<HTMLInputElement>) => {
            filterProjects(event.target.value);
        },
        [filterProjects]
    );

    const rowClass = useCallback(
        (row: Project) => {
            return selectedProject && selectedProject.projectId === row.projectId ? 'rdg-row-selected' : '';
        },
        [selectedProject]
    );

    // Create selectedRows Set for single row selection
    const selectedRows = useMemo(() => {
        return selectedProject && selectedProject.projectId ? new Set([selectedProject.projectId]) : new Set<number>();
    }, [selectedProject]);

    return (
        <div>
            <div className="input-group top-bottom-padding-8">
                <span className="input-group-addon input-group-addon-buffer">
                    <i className="fa fa-search"></i>
                </span>
                <input
                    className="form-control search-input"
                    id="projectSearch"
                    name="projectSearch"
                    onChange={handleProjectSearchChange}
                    placeholder="Search projects"
                    type="text"
                />
            </div>
            <div className="top-bottom-padding-8 scheduler-project-list">
                <DataGrid
                    className="project-table"
                    columns={columns}
                    defaultColumnOptions={{ resizable: true }}
                    onCellClick={onCellClick}
                    onSelectedRowsChange={onSelectedRowsChange}
                    onSortColumnsChange={handleSort}
                    rowClass={rowClass}
                    rowKeyGetter={(row: Project) => row.projectId}
                    rows={sortedRows}
                    selectedRows={selectedRows}
                    sortColumns={sortColumns}
                    style={{ height: 'calc(48vh - 160px - 50px)' }}
                />
            </div>
        </div>
    );
};

const arePropsEqual = (prevProps: ProjectListProps, nextProps: ProjectListProps) => {
    const { accordion } = nextProps;

    if (accordion && accordion.tab !== TAB_PROJECTS) {
        return true;
    }
    return false;
};

const MemoizedProjectList = memo(ProjectList, arePropsEqual);

const mapStateToProps = (state: any) => ({
    projects: state.project.projects,
    selectedProject: state.project.selectedProject,
    forceRerender: state.root.forceRerender, // Bit of a hack to get a re-render
});

const mapDispatchToProps = (dispatch: Dispatch) => ({
    setForceRerender: (render: boolean) => dispatch(setForceRerender(render)),
    onSelectProject: (selectedProject: Project) => dispatch(selectProject(selectedProject)),
    onSelectTimeline: (timeline?: Timeline) => dispatch(selectTimeline(timeline)),
    filterProjects: (search: string) => dispatch(filterProjects(search)),
});

export default connect(mapStateToProps, mapDispatchToProps)(MemoizedProjectList);
