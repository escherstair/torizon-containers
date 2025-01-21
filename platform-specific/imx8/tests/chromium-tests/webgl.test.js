import { get_tidy_main_webgl_report } from './index.js'

test('Open and parse webgl test page', async () => {
    const report = await get_tidy_main_webgl_report();
    expect(report['Context Name']).toContain('webgl2');
    expect(report['GL Version']).toContain('WebGL 2.0 (OpenGL ES 3.0 Chromium)');
    // matches any substring "Vivante"
    expect(report['Unmasked Renderer'][0]).toEqual(expect.stringContaining('Vivante'));
}, 100000);
