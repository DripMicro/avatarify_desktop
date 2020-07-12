#ifndef INFERENCEWORKER_H
#define INFERENCEWORKER_H

#include <QThread>
#include "camera/AsyncCameraCapture.h"
#include "predictors/IdentityPredictor.h"
#include "predictors/LibtorchFOMM.h"

class InferenceWorker : public QThread {
Q_OBJECT

public:
    explicit InferenceWorker(AsyncCameraCapture *camera);

Q_SIGNALS:
    void presentPreview(QImage generatedFrame);

public Q_SLOTS:

    void setAvatarPath(QString avatarPath);

    void stop();

    void run() override;

private:
    void inference();

    const int fpsLimit = 25;

    AsyncCameraCapture *m_camera;
    IdentityPredictor identityPredictor;
    LibtorchFOMM libtorchPredictor;
    QString m_avatarPath = "none";
    bool isAlive = true;
};


#endif //INFERENCEWORKER_H
