import {Tabs} from "../../ts/enums/tabs-enum";
import React from "react";
import {TabButton} from "./tab-button";

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
