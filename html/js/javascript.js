$(function () {
    function display(bool) {
        if (bool) {
            $("body").fadeIn(200)
            $("container").fadeIn(200)
            $("table").fadeIn(200)


        } else {
            $("body").hide()
        }
    }
    display(false)
    window.addEventListener("message", function (event) {
        const item = event.data;
        if (item.type === "garage") {
            if (item.status) {
                display(true)
                $('#table').empty();
                $('#name').text("Garage")
                for (const [key, value] of Object.entries(item.garage)) {
                    const table = document.getElementById("table");
                    const row = table.insertRow(0);
                    const cell1 = row.insertCell(0);
                    const cell2 = row.insertCell(1);
                    const cell3 = row.insertCell(2);
                    const cell4 = row.insertCell(3);
                    const cell5 = row.insertCell(4);
                    const cell6 = row.insertCell(5);
                    const cell7 = row.insertCell(6);
                    const cell8 = row.insertCell(7);
                    cell1.innerHTML = value.name;
                    cell2.innerHTML = value.kmh + "KMT";
                    cell3.innerHTML = value.vehicle_plate;
                    if (value.status == "Ledig") {
                        cell4.innerHTML = "" + "<span style=\"color:green\">" + value.status + "</span>";
                    };
                    if (value.status == "Optaget") {
                        cell4.innerHTML = "" + "<span style=\"color:red\">" + value.status + "</span>";
                    };
                    cell5.innerHTML = "" + value.fuel + "L";
                    var hpnew = value.hp / 10
                    cell6.innerHTML = "" + hpnew + "%";
                    cell7.innerHTML = '<img class="tagud" id="buttons" veh=' + value.vehicle + ' fuel=' + value.fuel + ' hp=' + value.hp + ' src="https://img.icons8.com/small/16/000000/car.png"/>';
                    cell8.innerHTML = '<img class="info" id="buttons" veh=' + value.vehicle + ' src="https://img.icons8.com/small/344/detective.png"/>';
                }
                const table = document.getElementById("table");
                const row = table.insertRow(0);
                const cell1 = row.insertCell(0);
                const cell2 = row.insertCell(1);
                const cell3 = row.insertCell(2);
                const cell4 = row.insertCell(3);
                const cell5 = row.insertCell(4);
                const cell6 = row.insertCell(5);
                const cell7 = row.insertCell(6);
                const cell8 = row.insertCell(7);
                cell1.innerHTML = "Navn";
                cell2.innerHTML = "Topfart";
                cell3.innerHTML = "Nummerplade";
                cell4.innerHTML = "Status";
                cell5.innerHTML = "Benzin";
                cell6.innerHTML = "Motor";
                cell7.innerHTML = "Tag ud";
                cell8.innerHTML = "Information";


            } else {
                display(false)
            }
        }
        if (item.type == "close") {
            display(false)
            Luk()
        }

    })

    document.onkeyup = function (data) {
        if (data.which === 27) {
            $("table").fadeOut(200)
            $("body").fadeOut(400)
            $.post("https://xmq_garage/luk", JSON.stringify({}));
        }
    }
    $('#table').on('click', '.tagud', function () {
        var veh = $(this).attr('veh');
        var fuel = $(this).attr('fuel');
        var hp = $(this).attr('hp');

        Luk()
        $.post("https://xmq_garage/tagud", JSON.stringify({
            veh: veh,
            fuel: fuel,
            hp: hp,
        }))
        return;
    });

    $('#table').on('click', '.info', function () {
        var index = $(this).attr('veh');
        index = index.replace("info", "")
        Luk()
        $.post("https://xmq_garage/info", JSON.stringify({
            veh: index
        }))
        return;
    });
})

function Luk() {
    $("body").fadeOut(200)
    $.post("https://xmq_garage/luk", JSON.stringify({}));
};


