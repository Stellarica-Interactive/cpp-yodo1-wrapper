#pragma once

class AdWrapper;

// Singleton manager that holds the platform-specific AdWrapper instance
class AdManager {
public:
    // Get singleton instance
    static AdManager& getInstance();

    // Get the ad wrapper (caller uses this to call ad functions)
    AdWrapper* getAdWrapper();

private:
    AdManager();
    ~AdManager() = default;
    AdManager(const AdManager&) = delete;
    AdManager& operator=(const AdManager&) = delete;

    AdWrapper* adWrapper_ = nullptr;
};