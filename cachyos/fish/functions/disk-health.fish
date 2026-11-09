function disk-health --description 'SMART health of every physical disk'
    begin
        string join \t DISK MODEL SMART WARNING SPARE USED HOURS MEDIA_ERRORS WRITTEN
        for disk in (__disk_health_physical_disks)
            __disk_health_row $disk
        end
    end | column -t -s \t
end

function __disk_health_physical_disks
    lsblk --nodeps --paths --json --output NAME,TRAN | jq -r '.blockdevices[] | select(.tran) | .name'
end

function __disk_health_row --argument-names disk
    sudo smartctl --json --all $disk | jq -r --arg disk $disk '
        .nvme_smart_health_information_log as $nvme
        | [ ($disk | ltrimstr("/dev/")),
            .model_name // "?",
            (.smart_status.passed | if . == true then "PASSED" elif . == false then "FAILED" else "?" end),
            $nvme.critical_warning // "-",
            ($nvme.available_spare | if . then "\(.)%" else "-" end),
            ($nvme.percentage_used | if . then "\(.)%" else "-" end),
            .power_on_time.hours // "-",
            $nvme.media_errors // "-",
            ($nvme.data_units_written | if . then "\(. * 512000 / 1e11 | round / 10) TB" else "-" end)
          ]
        | @tsv'
end
