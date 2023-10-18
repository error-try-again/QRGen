import {Tabs} from "../../ts/enums/tabs-enum.tsx";
import React from "react";
import {TabButton} from "./tab-button.tsx";

export const TabNav = (activeTab: Tabs, handleTabChange: (tab: Tabs) => void, setTab: React.Dispatch<React.SetStateAction<Tabs>>) => {
    return <>
        {Object.values(Tabs).map((tab: Tabs) => (
            <TabButton
                key={tab}
                activeTab={activeTab}
                tab={tab}
                label={tab}
                handleTabChange={handleTabChange}
                setTab={setTab}
            />
        ))}
    </>;
};
