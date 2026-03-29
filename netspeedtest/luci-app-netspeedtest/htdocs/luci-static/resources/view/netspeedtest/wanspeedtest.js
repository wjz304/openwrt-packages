// Copyright (C) 2023-2025 muink
// Copyright (C) 2019-2026 sirpdboy

'use strict';
'require view';
'require poll';
'require dom';
'require fs';
'require uci';
'require ui';
'require form';

var Timeout = 300 * 1000;  
var ResultFile = '/tmp/netspeedtest_result';
var SpeedtestScript = '/usr/bin/netspeedtest.sh';

return view.extend({
    load() {
        return Promise.all([
            L.resolveDefault(fs.stat('/usr/bin/ookla-speedtest'), {}),
            L.resolveDefault(fs.stat('/usr/bin/speedtest'), {}),
            L.resolveDefault(fs.read(ResultFile), null),
            L.resolveDefault(fs.stat(ResultFile), {}),
            uci.load('netspeedtest')
        ]);
    },

    detectVersions: function(res) {
        var hasOokla = !!(res[0] && res[0].path);
        var hasPython = !!(res[1] && res[1].path);
        
        return {
            ookla: hasOokla,
            python: hasPython,
            available: hasOokla || hasPython
        };
    },

    isTesting: function(resultContent, resultMtime) {
        if (!resultContent || resultContent.length === 0) return false;
        if (resultContent[0].trim() !== 'Testing') return false;
        
        var fileAge = Date.now() - resultMtime;
        return fileAge < Timeout;
    },

    parseResult: function(content) {
        if (!content || content.length === 0) {
            return { type: 'none', data: null };
        }
        
        var firstLine = content[0].trim();
        
        if (firstLine === 'Testing') {
            return { type: 'testing', data: null };
        }
        if (firstLine === 'Test failed') {
            return { type: 'failed', data: null };
        }
        
        var resultUrl = null;
        for (var i = 0; i < content.length; i++) {
            var line = content[i];
            if (line.match(/Result URL:/i)) {
                var urlMatch = line.match(/https?:\/\/[^\s]+/);
                if (urlMatch) {
                    resultUrl = urlMatch[0];
                    break;
                }
            }
        }
        
        if (resultUrl) {
            return { type: 'url', data: resultUrl };
        }
        
        if (firstLine.match(/^https?:\/\//) || firstLine.match(/\.png$/)) {
            return { type: 'url', data: firstLine };
        }
        
        if (firstLine.match(/Download:/i) || firstLine.match(/Upload:/i)) {
            return { type: 'speed', data: content.join('\n') };
        }
        
        var hasDownload = false;
        var hasUpload = false;
        for (var j = 0; j < content.length; j++) {
            if (content[j].match(/Download:/i)) hasDownload = true;
            if (content[j].match(/Upload:/i)) hasUpload = true;
        }
        
        if (hasDownload && hasUpload) {
            return { type: 'speed', data: content.join('\n') };
        }
        
        return { type: 'unknown', data: content.join('\n') };
    },

    startSpeedTest: function(version) {
        return fs.write(ResultFile, 'Testing\n')
            .then(function() {
                    var shellCmd = SpeedtestScript;
                    if (version) {
                        shellCmd += ' --version ' + version;
                    }
                    shellCmd += ' > /dev/null 2>&1 &';
                    console.log('Starting test with sh -c:', shellCmd);
                    return fs.exec('/bin/ash', ['-c', shellCmd])
                        .catch(function() {
                            return fs.exec('/bin/sh', ['-c', shellCmd]);
                        });
            });
    },

    poll_status(nodes, res) {
        var result_content = res[2] ? res[2].trim().split("\n") : [];
        var result_mtime = res[3] ? res[3].mtime * 1000 : 0;
        
        var result_stat = nodes.querySelector('#speedtest_result');
        var start_btn = nodes.querySelector('.cbi-button-apply');
        var result = this.parseResult(result_content);
        var is_testing = this.isTesting(result_content, result_mtime);

        if (start_btn) {
            start_btn.disabled = is_testing;
        }

        if (result_stat) {
            if (is_testing) {
                result_stat.innerHTML = "<span style='color:green;font-weight:bold;margin-left:20px'>" +
                    "<img src='/luci-static/resources/icons/loading.svg' height='17' style='vertical-align:middle; margin-right:5px'/> " +
                    _('Speed testing in progress...') +
                    "</span>";
                return;
            }
            
            switch(result.type) {
                case 'failed':
                    result_stat.innerHTML = "<span style='color:red;font-weight:bold;margin-left:20px'>" +
                        "⚠️ " + _('Test failed. Please check log for details.') +
                        "</span>";
                    break;
                    
                case 'url':
                    var imageUrl = result.data;
                    if (!imageUrl.match(/\.png$/)) {
                        imageUrl = imageUrl + '.png';
                    }
                    if (imageUrl.includes('speedtest.net/result/')) {
                        imageUrl = imageUrl.replace('/result/c/', '/result/');
                    }
                    
                    result_stat.innerHTML = "<div style='max-width:500px; margin-left:20px'>" +
                        "<a href='" + result.data + "' target='_blank'>" +
                        "<img src='" + result.data + "' style='max-width:100%; border-radius:4px; box-shadow:0 2px 4px rgba(0,0,0,0.1)' " +
                        "</a><br>" +
                        "</div>";
                    break;
                    
                case 'speed':
                    var lines = result.data.split('\n');
                    var download = '', upload = '', latency = '', packetLoss = '', server = '', isp = '';
                    
                    lines.forEach(function(line) {
                        if (line.match(/Download:/i)) download = line;
                        else if (line.match(/Upload:/i)) upload = line;
                        else if (line.match(/Latency:/i) || line.match(/Idle Latency:/i)) latency = line;
                        else if (line.match(/Packet Loss:/i)) packetLoss = line;
                        else if (line.match(/Server:/i)) server = line;
                        else if (line.match(/ISP:/i)) isp = line;
                    });
                    
                    var html = "<div style='margin-left:20px; padding:10px; background:#f5f5f5; border-radius:4px'>";
                    html += "<strong>" + _('Test Results:') + "</strong>";
                    
                    if (server) {
                        html += "<div style='margin-top:5px; padding:5px; color:#666'>" +
                                server.trim() + "</div>";
                    }
                    
                    if (download) {
                        html += "<div style='margin-top:10px; padding:8px; background:#e8f5e8; border-radius:4px'>" +
                                "<span style='font-weight:bold'>⬇️ " + _('Download:') + "</span> " +
                                "<span style='color:#2e7d32; font-weight:500'>" + download.replace(/Download:/i, '').trim() + "</span>" +
                                "</div>";
                    }
                    
                    if (upload) {
                        html += "<div style='margin-top:5px; padding:8px; background:#e3f2fd; border-radius:4px'>" +
                                "<span style='font-weight:bold'>⬆️ " + _('Upload:') + "</span> " +
                                "<span style='color:#1565c0; font-weight:500'>" + upload.replace(/Upload:/i, '').trim() + "</span>" +
                                "</div>";
                    }
                    
                    if (latency) {
                        html += "<div style='margin-top:5px; padding:5px; background:#f5f5f5; border-radius:4px'>" +
                                "<span style='font-weight:bold'>⏱️ " + _('Latency:') + "</span> " +
                                "<span style='color:#666'>" + latency.replace(/Latency:/i, '').replace(/Idle Latency:/i, '').trim() + "</span>" +
                                "</div>";
                    }
                    
                    if (packetLoss) {
                        html += "<div style='margin-top:5px; padding:5px; color:#666'>" +
                                packetLoss.trim() + "</div>";
                    }
                    
                    html += "</div>";
                    result_stat.innerHTML = html;
                    break;
                    
                case 'unknown':
                    result_stat.innerHTML = "<div style='margin-left:20px; padding:10px; background:#f5f5f5; border-radius:4px'>" +
                        "<strong>" + _('Test Results:') + "</strong><br>" +
                        "<pre style='margin:5px 0 0 0; font-family:inherit; white-space:pre-wrap; color:#2e7d32'>" + 
                        escapeHTML(result.data) + "</pre>" +
                        "</div>";
                    break;
                    
                default:
                    result_stat.innerHTML = "<span style='color:gray;margin-left:20px'>" +
                        "<em>" + _('No test results yet.') + "</em>" +
                        "</span>";
            }
        }
    },

    render(res) {
        var self = this;
        var has_ookla = !!(res[0] && res[0].path);
        var has_python = !!(res[1] && res[1].path);
        var result_content = res[2] ? res[2].trim().split("\n") : [];
        var result_mtime = res[3] ? res[3].mtime * 1000 : 0;

        var versions = this.detectVersions(res);
        var result = this.parseResult(result_content);
        var is_testing = this.isTesting(result_content, result_mtime);

        var m, s, o;
        m = new form.Map('netspeedtest', _('Wan SpeedTest'));

        s = m.section(form.TypedSection, '_result');
        s.anonymous = true;
        s.render = function(section_id) {
            var result_id = 'speedtest_result';
            
            if (is_testing) {
                return E('div', { id: result_id, class: 'cbi-section' }, [
                    E('span', { style: 'color:green;font-weight:bold;margin-left:20px' }, [
                        E('img', { 
                            src: '/luci-static/resources/icons/loading.svg', 
                            height: '17', 
                            style: 'vertical-align:middle; margin-right:5px' 
                        }),
                        _('Speed testing in progress...')
                    ])
                ]);
            }
            
            switch(result.type) {
                case 'failed':
                    return E('div', { id: result_id, class: 'cbi-section' }, [
                        E('span', { style: 'color:red;font-weight:bold;margin-left:20px' }, [
                            '⚠️ ' + _('Test failed. Please check log for details.')
                        ])
                    ]);
                    
                case 'url':
                    var imageUrl = result.data;
                    if (!imageUrl.match(/\.png$/)) {
                        imageUrl = imageUrl + '.png';
                    }
                    if (imageUrl.includes('speedtest.net/result/')) {
                        imageUrl = imageUrl.replace('/result/c/', '/result/');
                    }
                    
                    return E('div', { id: result_id, class: 'cbi-section' }, [
                        E('div', { style: 'max-width:500px; margin-left:20px' }, [
                            E('a', { href: result.data, target: '_blank' }, [
                                E('img', { 
                                    src: imageUrl,
                                    style: 'max-width:100%; border-radius:4px; box-shadow:0 2px 4px rgba(0,0,0,0.1)'
                                })
                            ]),
                            E('br'),
                            E('small', {}, [
                                E('a', { 
                                    href: result.data, 
                                    target: '_blank',
                                    style: 'display:inline-block; margin-top:5px; color:#0066cc'
                                }, _('View detailed results'))
                            ])
                        ])
                    ]);
                    
                case 'speed':
                    var lines = result.data.split('\n');
                    var download = '', upload = '', latency = '';
                    
                    lines.forEach(function(line) {
                        if (line.match(/Download:/i)) download = line;
                        else if (line.match(/Upload:/i)) upload = line;
                        else if (line.match(/Latency:/i) || line.match(/Idle Latency:/i)) latency = line;
                    });
                    
                    var children = [
                        E('strong', {}, _('Test Results:'))
                    ];
                    
                    if (download) {
                        children.push(
                            E('div', { 
                                style: 'margin-top:10px; padding:8px; background:#e8f5e8; border-radius:4px' 
                            }, [
                                E('span', { style: 'font-weight:bold' }, '⬇️ ' + _('Download:') + ' '),
                                E('span', { style: 'color:#2e7d32; font-weight:500' }, download.replace(/Download:/i, '').trim())
                            ])
                        );
                    }
                    
                    if (upload) {
                        children.push(
                            E('div', { 
                                style: 'margin-top:5px; padding:8px; background:#e3f2fd; border-radius:4px' 
                            }, [
                                E('span', { style: 'font-weight:bold' }, '⬆️ ' + _('Upload:') + ' '),
                                E('span', { style: 'color:#1565c0; font-weight:500' }, upload.replace(/Upload:/i, '').trim())
                            ])
                        );
                    }
                    
                    if (latency) {
                        children.push(
                            E('div', { 
                                style: 'margin-top:5px; padding:5px; background:#f5f5f5; border-radius:4px' 
                            }, [
                                E('span', { style: 'font-weight:bold' }, '⏱️ ' + _('Latency:') + ' '),
                                E('span', { style: 'color:#666' }, latency.replace(/Latency:/i, '').replace(/Idle Latency:/i, '').trim())
                            ])
                        );
                    }
                    
                    return E('div', { 
                        id: result_id,
                        class: 'cbi-section'
                    }, [
                        E('div', { style: 'margin-left:20px; padding:10px; background:#f5f5f5; border-radius:4px' }, children)
                    ]);
                    
                case 'unknown':
                    return E('div', { id: result_id, class: 'cbi-section' }, [
                        E('div', { style: 'margin-left:20px; padding:10px; background:#f5f5f5; border-radius:4px' }, [
                            E('strong', {}, _('Test Results:')),
                            E('br'),
                            E('pre', { 
                                style: 'margin:5px 0 0 0; font-family:inherit; white-space:pre-wrap; color:#2e7d32'
                            }, escapeHTML(result.data))
                        ])
                    ]);
                    
                default:
                    return E('div', { id: result_id, class: 'cbi-section' }, [
                        E('span', { style: 'color:gray;margin-left:20px' }, [
                            E('em', {}, _('No test results yet.'))
                        ])
                    ]);
            }
        };

        s = m.section(form.NamedSection, 'config', 'netspeedtest');
        s.anonymous = true;

        o = s.option(form.ListValue, 'test_version', _('Select Test Version'));
        
        if (has_ookla) {
            o.value('ookla', 'Ookla SpeedTest');
        }
        if (has_python) {
            o.value('python', 'Python speedtest-cli');
        }
        
        if (has_ookla) {
            o.default = 'ookla';
        } else if (has_python) {
            o.default = 'python';
        }
        
        o.write = function(section_id, formvalue) {
            uci.set('netspeedtest', section_id, 'test_version', formvalue);
            return uci.save('netspeedtest');
        };

        // 开始测试按钮
        o = s.option(form.Button, 'start', _('Start Speed Test'));
        o.inputtitle = _('Click to start speed test');
        o.inputstyle = 'apply';
        
        if (is_testing) {
            o.readonly = true;
        }

        o.onclick = function() {
            var btn = this;
            btn.disabled = true;
            
            var versionSelect = document.getElementById('widget.cbid.netspeedtest.config.test_version');
            if (!versionSelect) {
                versionSelect = document.querySelector('select[name="test_version"]');
            }
            var version = versionSelect ? versionSelect.value : (has_ookla ? 'ookla' : 'python');
            
            
                self.startSpeedTest(version)
                .then(function() {
                })
                .catch(function(e) {
                });
            
            return false;
        };

        return m.render()
        .then(L.bind(function(m, nodes) {
            nodes.result_mtime = result_mtime;
            poll.add(L.bind(function() {
                return Promise.all([
                    L.resolveDefault(fs.stat('/usr/bin/ookla-speedtest'), {}),
                    L.resolveDefault(fs.stat('/usr/bin/speedtest'), {}),
                    L.resolveDefault(fs.read(ResultFile), null),
                    L.resolveDefault(fs.stat(ResultFile), {})
                ]).then(L.bind(function(res) {
                    nodes.result_mtime = res[3] ? res[3].mtime * 1000 : 0;
                    this.poll_status(nodes, res);
                }, this));
            }, this), 2); // 2秒轮询
            
            return nodes;
        }, this, m));
    },
    
    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});

function escapeHTML(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}