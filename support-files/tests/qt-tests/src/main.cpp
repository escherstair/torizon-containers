// SPDX-License-Identifier: BSD-3-Clause
/*
** This code is an adaptation of examples/opengl/contextinfo example provided
** by Qt Company.
**
** Copyright (C) 2016 The Qt Company Ltd.
** Copyright (C) 2024 Toradex AG
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
*/

#include <QDebug>
#include <QGuiApplication>
#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QSurfaceFormat>

int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);

    QOpenGLContext context;

    if (!context.create()) {
        qCritical() << "We failed to create an OpenGL context";
        return -1;
    }

    QOffscreenSurface surface;
    surface.create();

    if (!surface.isValid()) {
        qCritical() << "We failed to create an offscreen surface";
        return -1;
    }

    if (!context.makeCurrent(&surface)) {
        qCritical() << "We failed to make OpenGL context the current";
        return -1;
    }

    qDebug() << "OpenGL Version:" << reinterpret_cast<const char *>(glGetString(GL_VERSION));
    qDebug() << "OpenGL Renderer:" << reinterpret_cast<const char *>(glGetString(GL_RENDERER));
    qDebug() << "OpenGL Vendor:" << reinterpret_cast<const char *>(glGetString(GL_VENDOR));

    return 0;
}
