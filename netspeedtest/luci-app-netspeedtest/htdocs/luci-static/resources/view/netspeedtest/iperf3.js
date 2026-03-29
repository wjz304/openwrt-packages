/*   Copyright (C) 2021-2026 sirpdboy herboy2008@gmail.com https://github.com/sirpdboy/luci-app-netspeedtest */
'use strict';
'require view';
'require fs';
'require ui';
'require uci';
'require form';
'require poll';

var state = { 
    running: false,
    port: 5201 
};

const logPath = '/tmp/netspeedtest.log';

async function checkProcess() {
    try {
        const res = await fs.exec('/usr/bin/pgrep', ['iperf3']);
        if (res.code === 0 && res.stdout.trim()) {
            return { running: true, pid: res.stdout.trim() };
        }
        
        const psRes = await fs.exec('/bin/ps', ['-w', '-C', 'iperf3', '-o', 'pid=']);
        const pid = psRes.stdout.trim();
        return {
            running: !!pid,
            pid: pid || null
        };
    } catch (err) {
        console.error('Process check error:', err);
        return { running: false, pid: null };
    }
}

function controlService(action, port) {
    const commands = {
        start: `/usr/bin/iperf3 -s -D -p ${port} --logfile ${logPath} 2>&1`,
        stop: '/usr/bin/killall -q iperf3'
    };

    return (action === 'start' 
        ? fs.exec('/bin/sh', ['-c', `mkdir -p /tmp/netspeedtest && touch ${logPath} && chmod 644 ${logPath}`])
        : Promise.resolve()
    ).then(() => fs.exec('/bin/sh', ['-c', commands[action]]))
    .catch(err => {
        console.error('Service control error:', err);
        throw err;
    });
}
function saveConfiguration(newPort, enabled) {
    const uciContent = `config netspeedtest 'config'
\toption iperf3port '${newPort}'
\toption iperf3_enabled '${enabled ? '1' : '0'}'
`;
    
    return fs.write('/etc/config/netspeedtest', uciContent)
        .then(() => {
            if (enabled) {
                return fs.exec('/etc/init.d/netspeedtest', ['enable']);
            } else {
                return fs.exec('/etc/init.d/netspeedtest', ['disable']);
            }
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
            const port = uci.get('netspeedtest', 'config', 'iperf3port');
            if (port) {
                state.port = parseInt(port);
            }
        });
    },

    render: function() {
        const statusIcon = E('span', { 'style': 'margin-right: 5px;' });
        const statusText = E('span');
        
        const portInput = E('input', {
            'type': 'number',
            'class': 'cbi-input-text',
            'style': 'width: 100px;',
            'value': state.port,
            'min': 1024,
            'max': 65535,
            'placeholder': '5201'
        });
        const enableCheckbox = E('input', {
            'type': 'checkbox',
            'id': 'iperf3_enable',
            'class': 'cbi-input-checkbox',
            'checked': state.enabled
        });
        const portError = E('span', {
            'class': 'error',
            'style': 'color: red; margin-left: 10px; display: none;'
        }, _('Port range must be 1024-65535'));

        const statusContainer = E('div', { 'class': 'cbi-map-descr' }, [
            statusIcon, 
            statusText
        ]);
        
        const toggleBtn = E('button', {
            'class': 'btn cbi-button',
            'click': ui.createHandlerFn(this, function() {
                const action = state.running ? 'stop' : 'start';
                toggleBtn.disabled = true;
                
                controlService(action, state.port)
                    .then(() => {
                        return new Promise(resolve => setTimeout(resolve, 500));
                    })
                    .then(() => checkProcess())
                    .then(res => {
                        state.running = res.running;
                        updateStatus();
                        toggleBtn.disabled = false;
                    })
                    .catch(err => {
                        ui.addNotification(null, E('p', _('Error: ') + err.message), 'error');
                        toggleBtn.disabled = false;
                    });
            })
        });

        const savePortBtn = E('button', {
            'class': 'btn cbi-button cbi-button-apply',
            'style': 'margin-left: 10px;',
            'click': ui.createHandlerFn(this, function() {
                const newPort = parseInt(portInput.value);
                if (isNaN(newPort) || newPort < 1024 || newPort > 65535) {
                    portError.style.display = 'inline';
                    return;
                }
                portError.style.display = 'none';
                saveConfiguration(newPort,state.enabled)
                
            })
        }, _('Save'));

        function updateStatus() {
            statusIcon.textContent = state.running ? '✓' : '✗';
            statusIcon.style.color = state.running ? 'green' : 'red';
            statusText.textContent = _('Iperf3 Server ') + (state.running ? _('RUNNING') : _('NOT RUNNING'));
            statusText.style.color = state.running ? 'green' : 'red';
            statusText.style['font-weight'] = 'bold'; 
            statusText.style['font-size'] = '0.92rem'; 
            toggleBtn.textContent = state.running ? _('Stop Server') : _('Start Server');
            toggleBtn.className = `btn cbi-button cbi-button-${state.running ? 'reset' : 'apply'}`;
            
            portInput.value = state.port;
        }

        statusIcon.textContent = '...';
        statusText.textContent = _('Checking status...');
        toggleBtn.textContent = _('Loading...');
        toggleBtn.disabled = true;

        const statusSection = E('div', { 'class': 'cbi-section' }, [
            E('div', { 'style': 'margin: 15px' }, [
                E('h3', {}, _('Throughput speedtest Iperf3')),
                statusContainer,
                
                E('div', {'class': 'cbi-value', 'style': 'margin-top: 20px'}, [
                    E('div', {'class': 'cbi-value-title'}, _('Port Setting')),
                    E('div', {'class': 'cbi-value-field'}, [
                        portInput,
                        savePortBtn,
                        portError
                    ])
                ]),
                
                E('div', {'class': 'cbi-value'}, [
                    E('div', {'class': 'cbi-value-title'}, _('Service Control')),
                    E('div', {'class': 'cbi-value-field'}, toggleBtn),
                ]),
                
                E('div', {'class': 'cbi-value'}, [
                    E('div', {'class': 'cbi-value-title'}, _('Download iperf3 client')),
                    E('div', {'class': 'cbi-value-field'}, [ 
                        E('div', { 
                            'class': 'cbi-value-field', 
                            'style': 'display: flex;' 
                        }, [
                            E('button', {
                                'class': 'btn cbi-button cbi-button-save',
                                'click': ui.createHandlerFn(this, () => window.open('https://iperf.fr/iperf-download.php', '_blank'))
                            }, _('Official Website')),
                            E('button', {
                                'class': 'btn cbi-button cbi-button-save',
                                'click': ui.createHandlerFn(this, () => window.open('https://github.com/sirpdboy/netspeedtest/releases', '_blank'))
                            }, _('GitHub'))
                        ])
                    ])
                ])
            ])
        ]);

        // 初始化状态检查
        checkProcess().then(res => {
            state.running = res.running;
            updateStatus();
            toggleBtn.disabled = false;
            
            // 启动轮询
            poll.add(() => {
                return checkProcess().then(res => {
                    if (res.running !== state.running) {
                        state.running = res.running;
                        updateStatus();
                    }
                });
            }, 5);
        });

        return statusSection;
    }
});