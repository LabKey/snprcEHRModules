/*
 * Copyright (c) 2015-2018 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Ext4.namespace('EHR.reports');

//this contains SNPRC-specific reports that should be loaded on the animal history page
//this file is registered with EHRService, and should auto-load whenever EHR's
//dependencies are requested, provided this module is enabled
EHR.reports.urinalysis = function(panel, tab) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'urinalysisPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};
EHR.reports.miscTests = function(panel, tab) {
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'miscPivot',
        title: "Under construction - additional work is still needed on this report", //By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};
EHR.reports.hematology = function(panel, tab)
{
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'hematologyPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable,
        sort: '-date'
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank
    //var miscConfig = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'hematologyMisc',
    //    title: "Misc Tests" + title,
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: miscConfig
    //});

    // Reference range data not yet split into separate min/max values so disabling for now
    //var resultsConfig = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'hematologyRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: resultsConfig
    //});
};

EHR.reports.bloodChemistry = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'chemPivot',
        title: "By Panel" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank. Uncomment when/if
    // ehr_lookups.lab_tests data changes

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'chemMisc',
    //    title: "Misc Tests:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});


    // Reference range data not yet split into separate min/max values so disabling for now

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'chemistryRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});
};

EHR.reports.surveillance = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'surveillancePivot',
        title: "By Panel" + title,
        titleField: 'Id',
        sort: '-date',
        filters: filterArray.nonRemovable,
        removeableFilters: filterArray.removable
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });

    // All tests are currently configured to be part of the panel, so this will always be blank. Uncomment when/if
    // ehr_lookups.lab_tests data changes

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'surveillanceMisc',
    //    title: "Misc Tests:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});


    // Reference range data not yet split into separate min/max values so disabling for now

    //config = panel.getQWPConfig({
    //    schemaName: 'study',
    //    queryName: 'surveillanceRefRange',
    //    //viewName: 'Plus Ref Range',
    //    title: "Reference Ranges:",
    //    titleField: 'Id',
    //    sort: '-date',
    //    filters: filterArray.nonRemovable,
    //    removeableFilters: filterArray.removable
    //});
    //
    //tab.add({
    //    xtype: 'ldk-querycmp',
    //    style: 'margin-bottom:20px;',
    //    queryConfig: config
    //});
};

EHR.reports.proceduresBeforeDisposition = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    var config = panel.getQWPConfig({
        schemaName: 'study',
        queryName: 'encounters',
        viewName: 'ProceduresBeforeDisposition',
        title: "Procedure Before Disposition " + title,
        filters: filterArray.nonRemovable,
        removeableFilters: [LABKEY.Filter.create('survivorship/survivorshipInDays', 3, LABKEY.Filter.Types.LESS_THAN_OR_EQUAL)]
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom:20px;',
        queryConfig: config
    });
};

EHR.reports.currentBlood = function(panel, tab){
    var filterArray = panel.getFilterArray(tab);
    var title = panel.getTitleSuffix();

    tab.add({
        html: 'This report summarizes the blood available for the animals below.  ' +
                '<br><br>If there have been recent blood draws for the animal, a graph will show the available blood over time.  On the graph, dots indicate dates when either blood was drawn or a previous blood draw fell off.  The horizontal lines indicate the maximum allowable blood that can be drawn on that date.',
        border: false,
        style: 'padding-bottom: 20px;'
    });

    tab.add({
        xtype: 'ldk-querycmp',
        style: 'margin-bottom: 10px;',
        queryConfig: panel.getQWPConfig({
            title: 'Summary',
            schemaName: 'study',
            queryName: 'Demographics',
            viewName: 'Blood Draws',
            filterArray: filterArray.removable.concat(filterArray.nonRemovable)
        })
    });

    var subjects = tab.filters.subjects || [];

    if (subjects.length){
        tab.add({
            xtype: 'snprc-bloodsummarypanel',
            subjects: subjects
        });
    }
    else
    {
        panel.resolveSubjectsFromHousing(tab, function(subjects, tab){
            tab.add({
                xtype: 'snprc-bloodsummarypanel',
                subjects: subjects
            });
        }, this);
    }
};

// Shared with SNPRC by WNPRC
// https://github.com/WNPRC-EHR-Services/wnprc-modules/blob/10350e7a0b594dc681e97df676142145bc38913b/WNPRC_EHR/resources/web/wnprc_ehr/animalPortal.js)
EHR.reports.FileRepository =  function(panel,tab) {
    if (tab.filters.subjects){
        var animalIds = tab.filters.subjects[0];
        renderFiles(animalIds,tab);
    }

    function renderFiles(subjects, tab)
    {
        if (!subjects.length){
            tab.add({
                html:'No animals were found',
                border : false
            });

            return;
        }

        if (subjects.length === 0)
            return;

        // WebdavFileSystem depends on ExtJS3 so load it it dynamically
        LABKEY.requiresExt3ClientAPI(function() {
            Ext.onReady(function() {
                var containerPath = LABKEY.container.path + '/FileRepository';
                var animalFolder = new LABKEY.FileSystem.WebdavFileSystem({baseUrl: LABKEY.ActionURL.getBaseURL() + '_webdav' + containerPath + '/@files/' + animalIds + '/'});
                var location = {id: animalIds};
                console.log("Id of animal  " + animalIds);

                var panel = tab.add({id: 'filesDiv', style: 'margin-bottom:20px'});

                var handler = function (location) {
                    var webPart = new LABKEY.WebPart({
                        title: 'File Repository for ' + animalIds,
                        partName: 'Files',
                        renderTo: 'filesDiv-body',
                        containerPath: containerPath,
                        partConfig: {path: location},
                        success: function () {
                            panel.setHeight(450);
                        }
                    });
                    webPart.render();

                };

                animalFolder.listFiles({
                    success: function () {
                        console.log("success", arguments);
                        handler(location.id);
                    },
                    path: "/",
                    failure: function () {
                        LABKEY.Security.getUserPermissions({
                            containerPath: containerPath,
                            success: function (userPermsInfo) {
                                var hasInsert = false;
                                for (var i = 0; i < userPermsInfo.container.effectivePermissions.length; i++) {
                                    if (userPermsInfo.container.effectivePermissions[i] == 'org.labkey.api.security.permissions.InsertPermission') {
                                        hasInsert = true;
                                    }
                                }
                                if (hasInsert) {
                                    panel.add({
                                        xtype: 'ldk-webpartpanel',
                                        title: 'File Repository for ' + animalIds,
                                        items: [
                                            {
                                                xtype: 'label',
                                                text: 'No directory found for this animal. To upload files, you must create the folders first.  '
                                            },
                                            {
                                                xtype: 'label',
                                                html: '<br/><br/>'

                                            },
                                            {
                                                xtype: 'button',
                                                style: 'margin-left: 10px;',
                                                border: true,
                                                text: 'Create Folders',
                                                handler: function () {
                                                    animalFolder.createDirectory({
                                                        path: "/",
                                                        success: function () {
                                                            const folders = [
                                                                "Surgery Sheets",
                                                                "Radiology Reports",
                                                                "Misc Docs",
                                                                "Images",
                                                                "Pathology Reports",
                                                                "Lab Reports",
                                                                "Procurement Docs",
                                                                "Dental Records",
                                                                "Cardiology Docs",
                                                                "Anesthesia Reports"
                                                            ];

                                                            var createdCount = 0;

                                                            folders.forEach(function (folder) {
                                                                animalFolder.createDirectory({
                                                                    path: "/" + folder,
                                                                    success: function () {
                                                                        console.log("created " + folder + " folder for " + animalIds);
                                                                        createdCount++;
                                                                        if (createdCount === folders.length) {
                                                                            handler(location.id);
                                                                        }
                                                                    },
                                                                    failure: function (error) {
                                                                        console.error("failed to create " + folder + " folder" + error.status)
                                                                    }
                                                                })
                                                            }),
                                                                    console.log("folder created for " + animalIds);
                                                        },
                                                        failure: function (error) {
                                                            console.error("failed to created folder" + error.status)
                                                        }
                                                    })

                                                }

                                            }]
                                    });
                                }
                                else {
                                    panel.add({
                                        xtype: 'ldk-webpartpanel',
                                        title: 'File Repository for ' + animalIds,
                                        items: [
                                            {
                                                xtype: 'label',
                                                text: 'The current animal does not have any files, and you do not have permission to upload new files.'
                                            }]
                                    });
                                }
                            },
                            failure: function (error, response) {
                                var message;
                                if (response.status == 404) {
                                    message = 'The folder ' + containerPath + ' does not exist, so no files can be shown or uploaded. Contact EHR services to correct the configuration.';
                                }
                                else if (response.status == 401 || response.status == 403) {
                                    message = 'You do not have permission to upload or view files. Contact EHR services to get permission.';
                                }
                                else {
                                    message = 'There was an error attempting to load the file data: ' + response.status;
                                }
                                panel.add({
                                    xtype: 'ldk-webpartpanel',
                                    title: 'File Repository for ' + animalIds,
                                    items: [
                                        {
                                            xtype: 'label',
                                            text: message
                                        }]
                                });
                            }
                        });
                    },

                    forceReload: true
                });


                if (File && File.panel && File.panel.Browser && File.panel.Browser._pipelineConfigurationCache) {
                    File.panel.Browser._pipelineConfigurationCache = {};
                }
            });
        }, this);
    }
};

EHR.reports.snprcClinicalHistory = function(panel, tab, showActionsBtn, includeAll) {
    if (tab.filters.subjects) {
        renderSubjects(tab.filters.subjects, tab);
    } else {
        panel.resolveSubjectsFromHousing(tab, renderSubjects, this);
    }

    function renderSubjects(subjects, tab) {
        if (subjects.length > 10) {
            tab.add({
                html: 'Because more than 10 subjects were selected, the condensed report is being shown.  Note that you can click the animal ID to open this same report in a different tab, showing that animal in more detail or click the link labeled \'Show Hx\'.',
                style: 'padding-bottom: 20px;',
                border: false
            })
            var filterArray = panel.getFilterArray(tab);
            var title = panel.getTitleSuffix();
            tab.add({
                xtype: 'ldk-querycmp',
                style: 'margin-bottom:20px',
                queryConfig: {
                    title: 'Overview' + title,
                    schemaName: 'study',
                    queryName: 'demographics',
                    viewName: 'Snapshot',
                    filterArray: filterArray.removable.concat(filterArray.nonRemovable)
                }
            });
            return;
        }

        if(!subjects.length) {
            tab.add({
                html: 'No animals were found.',
                border: false
            });
            return;
        }
        tab.addCls('ehr-snapshotsubpanel');
        var currentDate = new Date();
        var minDate = includeAll ? null : Ext4.Date.add(currentDate, Ext4.Date.DAY, -30);
        var toAdd = [];
        Ext4.each(subjects, function(s){
            toAdd.push({
                html: '<span style="font-size: large;"><b>Animal: ' + s + '</b></span>',
                style: 'padding-bottom: 20px;',
                border: false
            });

            toAdd.push({
                xtype: EHR.reports.clinicalHistoryPanelXtype,
                showActionsButton: !!showActionsBtn,
                hrefTarget: '_blank',
                border: false,
                subjectId: s
            });

            toAdd.push({
                html: '<b>Chronological History:</b><hr>',
                style: 'padding-top: 5px;',
                border: false
            });


            toAdd.push({
                xtype: 'snprc-clinicalhistorypanel',
                border: true,
                subjectId: s,
                autoLoadRecords: true,
                minDate: minDate,
                //maxGridHeight: 1000,
                hrefTarget: '_blank',
                style: 'margin-bottom: 20px;'
            });


        }, this);

        if (toAdd.length) {
            tab.add(toAdd);
        }
    }
};

EHR.reports.SndEvents = function (panel, tab) {

    var containerPath = LABKEY.container.path;

    let target = tab.add({xtype: 'ldk-contentresizingpanel'});

    try {
        // according to the DOM spec, the mutation observer should be GC'd if/when the target node is removed
        let observer = new MutationObserver(target.fireEvent.bind(target, 'contentsizechange'));
        observer.observe(target.getEl().dom, {childList: true, subtree: true});

    }
    catch (e) {
        console.warn("Could not attach mutation observer. Resizing will rely on older APIs, may not work right");
    }

    LABKEY.Security.getUserPermissions({
            containerPath: containerPath,
            success: (userPermsInfo) => {
                let config = {
                    filterConfig: JSON.stringify({
                        filters: tab.filters
                    }),
                    hasReadPermission: userPermsInfo.container.effectivePermissions.includes('org.labkey.snd.security.permissions.SNDViewerPermission'),
                    hasWritePermission: userPermsInfo.container.effectivePermissions.includes('org.labkey.snd.security.permissions.SNDEditorPermission')
                }

                const wp = new LABKEY.WebPart({
                    partConfig: config,
                    partName: 'SND Events Widget Webpart',
                    renderTo: target.renderTarget
                })

                wp.render()
            }
    })

}
