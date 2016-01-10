{
  'targets': [{
    'target_name': 'robotjs',
    'include_dirs': [
        "<!(node -e \"require('nan')\")"
    ],
    
    'cflags': [
      '-Wall',
      '-Wparentheses',
      '-Winline',
      '-Wbad-function-cast',
      '-Wdisabled-optimization'
    ],
    
    'conditions': [
      ['OS == "mac"', {
        'include_dirs': [
          'System/Library/Frameworks/CoreFoundation.Framework/Headers',
          'System/Library/Frameworks/Carbon.Framework/Headers',
          'System/Library/Frameworks/ApplicationServices.framework/Headers',
          'System/Library/Frameworks/OpenGL.framework/Headers',
        ],
        'link_settings': {
          'libraries': [
            '-framework Carbon',
            '-framework CoreFoundation',
            '-framework ApplicationServices',
            '-framework OpenGL',
            '$(SDKROOT)/System/Library/Frameworks/AppKit.framework'
          ]
        },
        'sources': [
          'src/cursor_darwin.mm'
        ]
      }],
      
      ['OS == "linux"', {
        'link_settings': {
          'libraries': [
            '-lpng',
            '-lz',
            '-lX11',
            '-lXtst'
          ]
        },
        
        'sources': [
          'src/xdisplay.c'
        ]
      }],

      ["OS=='win'", {
        'defines': ['IS_WINDOWS'],
        'msbuild_settings': {
          'ClCompile': {
            'ExceptionHandling': 'Async',
            #'RuntimeTypeInfo': 1,
            'RuntimeLibrary':'MultiThreadedDLL',
            'CompileAsManaged':'true',
              'AdditionalOptions': [
                '/clr',
                '/TP',
                '/TC'
                '/c4005'
              ]
          }
        },
        'sources': [
          #'src/cursor_win.cc'
        ]
      }]
    ],
    
    'sources': [
      'src/robotjs.cc',
      'src/deadbeef_rand.c',
      'src/mouse.c',
      'src/keypress.c',
      'src/keycode.c',
      'src/screen.c',
      'src/screengrab.c',
      'src/snprintf.c',
      'src/MMBitmap.c'
    ]
  }]
}