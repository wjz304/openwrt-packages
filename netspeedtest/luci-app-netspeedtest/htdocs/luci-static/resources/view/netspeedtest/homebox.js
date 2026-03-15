/*   Copyright (C) 2021-2026 sirpdboy herboy2008@gmail.com */
'use strict';
'require view';
'require fs';
'require ui';
'require uci';
'require form';
'require poll';

var state = { 
    running: false,
    port: 3300,
    enabled: false,
    operationInProgress: false,
    operationType: null  // 'start' 或 'stop'
};

const logPath = '/tmp/netspeedtest.log';

function checkProcess(quick = false) {
    if (quick) {
        return fs.exec('/usr/bin/pgrep', ['homebox'])
            .then(function(res) {
                return res.code === 0 && res.stdout.trim() !== '';
            })
            .catch(function() {
                return false;
            });
    } else {
        return fs.exec('/usr/bin/pgrep', ['homebox'])
            .then(function(res) {
                if (res.code === 0 && res.stdout.trim()) {
                    return { 
                        running: true, 
                        pid: res.stdout.trim() 
                    };
                }
                return fs.exec('/bin/ps', ['-w', '-C', 'homebox', '-o', 'pid='])
                    .then(function(psRes) {
                        var pid = psRes.stdout.trim();
                        return {
                            running: pid !== '',
                            pid: pid || null
                        };
                    });
            })
            .catch(function(err) {
                return { running: false, pid: null };
            });
    }
}

function controlService(action, port) {
    if (action === 'start') {
        return fs.exec('/usr/bin/killall', ['homebox'])
            .catch(function() { return Promise.resolve(); })
            .then(function() {
                var command = 'nohup /usr/bin/homebox serve --port ' + port + ' > ' + logPath + ' 2>&1 &';
                return fs.exec('/bin/sh', ['-c', command]);
            });
    } else {
        return fs.exec('/etc/init.d/netspeedtest', ['stop']);
    }
}

function saveConfiguration(newPort, enabled) {
    const uciContent = `config netspeedtest 'config'
\toption homebox_port '${newPort}'
\toption homebox_enabled '${enabled ? '1' : '0'}'
`;
    
    return fs.write('/etc/config/netspeedtest', uciContent)
        .then(() => {
            if (enabled) {
                return fs.exec('/etc/init.d/netspeedtest', ['enable']);
            } else {
                return fs.exec('/etc/init.d/netspeedtest', ['disable']);
            }
        })
        .then(() => {
            return uci.load('netspeedtest');
        });
}

return view.extend({
    handleSaveApply: null,
    handleSave: null,
    handleReset: null,
    
    load: function() {
        return Promise.all([
            uci.load('netspeedtest')
        ]).then(() => {
            var port = uci.get('netspeedtest', 'config', 'homebox_port');
            if (port) {
                state.port = parseInt(port);
            }
            
            var enabled = uci.get('netspeedtest', 'config', 'homebox_enabled');
            state.enabled = enabled === '1';
        });
    },
    
    render: function() {
        var container = E('div');
        var statusSection = E('div', { 'class': 'cbi-section' });
        var statusIcon = E('span', { 'style': 'margin-right: 5px;' });
        var statusText = E('span');
        var toggleBtn = E('button', { 'class': 'btn cbi-button' });
        
        var saveBtn = E('button', { 
            'class': 'btn cbi-button cbi-button-apply',
            'style': 'margin-left: 10px;'
        }, _('Save'));
        
        var enableCheckbox = E('input', {
            'type': 'checkbox',
            'id': 'homebox_enable',
            'class': 'cbi-input-checkbox'
        });
        var statusMessage = E('div', { style: 'text-align: center; padding: 2em;' }, [
            E('div', { style: 'font-size: 5em; color: #f39c12; margin-bottom: 0.2em;' }, '⚠️'),
            E('h2', {}, _('Homebox Service Not Running')),
            E('p', { style: 'color: #666; margin-top: 1em;' }, _('Please start the Homebox service'))
        ]);


        var isHttps = window.location.protocol === 'https:';
        var iframe;
        
        var portInput = E('input', {
            'type': 'number',
            'class': 'cbi-input-text',
            'style': 'width: 100px;',
            'value': state.port,
            'min': 1024,
            'max': 65535,
            'placeholder': '3300'
        });
        
        var portError = E('span', {
            'class': 'error',
            'style': 'color: red; margin-left: 10px; display: none;'
        }, _('Port range must be 1024-65535'));

        function createHttpsButton() {
            return E('div', {
                style: 'text-align: center; padding: 2em;'
            }, [
                E('h2', {}, _('Homebox Control panel')),
                E('p', {}, _('Due to browser security policies, the Homebox interface https cannot be embedded directly.')),
                E('a', {
                    href: 'http://' + window.location.hostname + ':' + state.port,
                    target: '_blank',
                    class: 'cbi-button cbi-button-apply',
                    style: 'display: inline-block; margin-top: 1em; padding: 10px 20px; font-size: 16px; text-decoration: none; color: white;'
                }, _('Open Web Interface'))
            ]);
        }

        function updateStatus() {
            statusIcon.textContent = state.running ? '✓' : '✗';
            statusIcon.style.color = state.running ? 'green' : 'red';
            statusText.textContent = _('Homebox Server') + ' ' + (state.running ? _('RUNNING') : _('NOT RUNNING'));
            statusText.style.color = state.running ? 'green' : 'red';
            statusText.style.fontWeight = 'bold'; 
            statusText.style.fontSize = '0.92rem'; 
            
            if (state.operationInProgress) {
                if (state.operationType === 'start') {
                    toggleBtn.textContent = _('Starting...');
                } else if (state.operationType === 'stop') {
                    toggleBtn.textContent = _('Stopping...');
                }
                toggleBtn.disabled = true;
                if (state.operationType === 'stop' && !state.running) {
                    console.log('Stop confirmed - operation complete');
                    state.operationInProgress = false;
                    state.operationType = null;
                    toggleBtn.textContent = state.running ? _('Stop Server') : _('Start Server');
                    toggleBtn.className = 'btn cbi-button cbi-button-' + (state.running ? 'reset' : 'apply');
                    toggleBtn.disabled = false;
                } else if (state.operationType === 'start' && state.running) {
                    console.log('Start confirmed - operation complete');
                    state.operationInProgress = false;
                    state.operationType = null;
                    toggleBtn.textContent = state.running ? _('Stop Server') : _('Start Server');
                    toggleBtn.className = 'btn cbi-button cbi-button-' + (state.running ? 'reset' : 'apply');
                    toggleBtn.disabled = false;
                } 
            } else {
                toggleBtn.textContent = state.running ? _('Stop Server') : _('Start Server');
                toggleBtn.className = 'btn cbi-button cbi-button-' + (state.running ? 'reset' : 'apply');
                toggleBtn.disabled = false;
            }

            enableCheckbox.checked = state.enabled;
            portInput.value = state.port;
            
            container.innerHTML = '';
            if (state.running) {
                if (isHttps) {
                    container.appendChild(createHttpsButton());
                } else {
                    iframe = E('iframe', {
                        src: 'http://' + window.location.hostname + ':' + state.port,
                        style: 'border:none;width: 100%; min-height: 80vh; border: none; border-radius: 3px;overflow:hidden !important;'
                    });
                    container.appendChild(iframe);
                }
            } else {
                container.appendChild(statusMessage);
            }
        }

        toggleBtn.addEventListener('click', function(ev) {
            ev.preventDefault();
            
            if (toggleBtn.disabled || state.operationInProgress) return;
            
            var action = state.running ? 'stop' : 'start';
            var startTime = Date.now();

            state.operationInProgress = true;
            state.operationType = action;
            updateStatus();
            
            controlService(action, state.port)
                .then(function() {
                    return new Promise(function(resolve, reject) {
                        var checkCount = 0;
                        var maxChecks = 30; 
                        
                        function doCheck() {
                            checkProcess(true).then(function(isRunning) {
                                if (action === 'stop' && !isRunning) {
                                    console.log('Stop success after', Date.now() - startTime, 'ms');
                                    resolve({ running: false });
                                } else if (action === 'start' && isRunning) {
                                    console.log('Start success after', Date.now() - startTime, 'ms');
                                    checkProcess().then(resolve).catch(resolve);
                                } else if (checkCount < maxChecks) {
                                    checkCount++;
                                    setTimeout(doCheck, 200); 
                                } else {
                                   console.log('Check timeout, using full check');

                                    checkProcess().then(resolve).catch(resolve);
                                }
                            }).catch(function() {
                                if (checkCount < maxChecks) {
                                    checkCount++;
                                    setTimeout(doCheck, 100);
                                } else {
                                    checkProcess().then(resolve).catch(resolve);
                                }
                            });
                        }
                        
                        doCheck();
                    });
                })
                .then(function(res) {
                    if (res) {
                        if (typeof res === 'boolean') {
                            state.running = res;
                        } else {
                            state.running = res.running || false;
                            if (res.port) {
                                state.port = res.port;
                            }
                        }
                    }
                    
                    state.operationInProgress = false;
                    state.operationType = null;
                    updateStatus();
                    
                    var message = action === 'start' ? 
                        _('Homebox server started on port %s').replace('%s', state.port) : 
                        _('Homebox server stopped');
                })
                .catch(function(err) {
                    console.error('Service control error:', err);
                    
                    // 发生错误时重新检查
                    checkProcess().then(function(res) {
                        state.running = res.running || false;
                        if (res.port) state.port = res.port;
                        
                        state.operationInProgress = false;
                        state.operationType = null;
                        updateStatus();
                        
                    }).catch(function() {
                        state.operationInProgress = false;
                        state.operationType = null;
                        updateStatus();
                    });
                });
        });

        saveBtn.addEventListener('click', function(ev) {
            ev.preventDefault();
            
            var newPort = parseInt(portInput.value, 10);
            if (isNaN(newPort) || newPort < 1024 || newPort > 65535) {
                portError.style.display = 'inline';
                return;
            }
            portError.style.display = 'none';
            
            saveBtn.disabled = true;
            saveBtn.textContent = _('Saving...');
            
            saveConfiguration(newPort, enableCheckbox.checked)
                .then(function() {
                    state.port = newPort;
                    state.enabled = enableCheckbox.checked;
                    updateStatus();
                })
                .catch(function(err) {
                })
                .finally(function() {
                    saveBtn.disabled = false;
                    saveBtn.textContent = _('Save');
                });
        });

        enableCheckbox.addEventListener('change', function(ev) {
            saveConfiguration(state.port, enableCheckbox.checked)
                .then(function() {
                    state.enabled = enableCheckbox.checked;
                    updateStatus();
                    
                    var message = enableCheckbox.checked ? 
                        _('Auto start enabled') : 
                        _('Auto start disabled');
                })
                .catch(function(err) {
                    enableCheckbox.checked = state.enabled;
                });
        });

        statusSection.appendChild(E('div', { 'style': 'margin: 15px' }, [
            E('h3', {}, _('Throughput speedtest Homebox')),
            E('div', { 'class': 'cbi-map-descr' }, [statusIcon, statusText]),
            
            E('div', {'class': 'cbi-value'}, [
                E('div', {'class': 'cbi-value-title'}, _('Auto Start')),
                E('div', {'class': 'cbi-value-field'}, [
                    enableCheckbox,
                    E('label', {'for': 'homebox_enable', 'style': 'margin-left: 5px;'})
                ])
            ]),
            
            E('div', {'class': 'cbi-value' }, [
                E('div', {'class': 'cbi-value-title'}, _('Port Setting')),
                E('div', {'class': 'cbi-value-field', 'style': 'align-items: center;'}, [
                    portInput,
                    saveBtn,
                    portError
                ])
            ]),
            
            E('div', {'class': 'cbi-value'}, [
                E('div', {'class': 'cbi-value-title'}, _('Service Control')),
                E('div', {'class': 'cbi-value-field'}, toggleBtn)
            ])
        ]));

        checkProcess().then(function(res) {
            state.running = res.running;
            if (res.port) {
                state.port = res.port;
            }
            updateStatus();
            
            poll.add(function() {
                return checkProcess().then(function(res) {
                    if (res.running !== state.running || (res.port && res.port !== state.port)) {
                        state.running = res.running;
                        if (res.port) {
                            state.port = res.port;
                        }
                        updateStatus();
                    }
                });
            }, 5);
        });

        return E('div', {}, [
            statusSection,
            container
        ]);
    }
});